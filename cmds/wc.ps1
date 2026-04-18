#Requires -Version 5.1
<#
.SYNOPSIS
    Emulates a scoped subset of the Linux `wc` command.

.DESCRIPTION
    Counts lines, words, and bytes from files or stdin-like pipeline input.
    The current MVP supports default output plus `-l`, `-w`, and `-c`.

    Behavioral differences from Linux:
    - Character-count mode (`-m`) is not implemented yet.
    - Maximum line length mode (`-L`) is not implemented yet.
    - For PowerShell pipeline input, line and byte counting follows the text
      stream reconstructed inside the script rather than raw Unix pipe bytes.

.PARAMETER CountLines
    Output the newline-based line count.

.PARAMETER CountWords
    Output the word count.

.PARAMETER CountBytes
    Output the byte count.

.PARAMETER Path
    One or more files to read.

.PARAMETER InputObject
    Pipeline text input when no file path is supplied.

.EXAMPLE
    # Linux:
    wc .\app.log

    # pscompat:
    .\cmds\wc.ps1 .\app.log

.EXAMPLE
    Get-Content .\app.log | .\cmds\wc.ps1 -l
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Alias('l')]
    [switch]$CountLines,

    [Alias('w')]
    [switch]$CountWords,

    [Alias('c')]
    [switch]$CountBytes,

    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Path,

    [Parameter(ValueFromPipeline = $true)]
    [AllowNull()]
    [object]$InputObject
)

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
. (Join-Path (Join-Path $repoRoot 'lib') 'common.ps1')
. (Join-Path (Join-Path $repoRoot 'lib') 'pipeline.ps1')

$ErrorActionPreference = 'Stop'

function Get-WcMetricsFromBytes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [byte[]]$Bytes
    )

    $utf8 = New-Object System.Text.UTF8Encoding($false, $false)
    $text = $utf8.GetString($Bytes)
    $wordMatches = [System.Text.RegularExpressions.Regex]::Matches($text, '\S+')
    $lineCount = 0

    foreach ($currentByte in $Bytes) {
        if ($currentByte -eq 10) {
            $lineCount++
        }
    }

    [pscustomobject]@{
        Lines = $lineCount
        Words = $wordMatches.Count
        Bytes = $Bytes.Length
    }
}

function Format-WcOutput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [psobject]$Metrics,

        [AllowNull()]
        [string]$Label,

        [Parameter(Mandatory)]
        [bool]$UseDefaultSet,

        [Parameter(Mandatory)]
        [bool]$IncludeLines,

        [Parameter(Mandatory)]
        [bool]$IncludeWords,

        [Parameter(Mandatory)]
        [bool]$IncludeBytes
    )

    $parts = New-Object 'System.Collections.Generic.List[string]'

    if ($UseDefaultSet -or $IncludeLines) {
        $parts.Add([string]$Metrics.Lines) | Out-Null
    }

    if ($UseDefaultSet -or $IncludeWords) {
        $parts.Add([string]$Metrics.Words) | Out-Null
    }

    if ($UseDefaultSet -or $IncludeBytes) {
        $parts.Add([string]$Metrics.Bytes) | Out-Null
    }

    if (-not [string]::IsNullOrEmpty($Label)) {
        $parts.Add($Label) | Out-Null
    }

    return ($parts.ToArray() -join ' ')
}

$pipelineBuffer = New-PsCompatLineBuffer
$receivedPipelineInput = $false

foreach ($pipelineItem in $input) {
    $receivedPipelineInput = $true
    Add-PsCompatPipelineLine -Buffer $pipelineBuffer -InputObject $pipelineItem
}

$useDefaultSet = -not ($CountLines -or $CountWords -or $CountBytes)
$hasPath = $null -ne $Path -and $Path.Count -gt 0

if ($hasPath) {
    $hadError = $false
    $runningTotals = [pscustomobject]@{
        Lines = 0
        Words = 0
        Bytes = 0
    }

    foreach ($currentPath in $Path) {
        try {
            $resolvedPath = Resolve-PsCompatPath -Path $currentPath
            $bytes = [System.IO.File]::ReadAllBytes($resolvedPath)
            $metrics = Get-WcMetricsFromBytes -Bytes $bytes

            $runningTotals.Lines += $metrics.Lines
            $runningTotals.Words += $metrics.Words
            $runningTotals.Bytes += $metrics.Bytes

            Write-Output (Format-WcOutput -Metrics $metrics -Label $currentPath -UseDefaultSet $useDefaultSet -IncludeLines $CountLines -IncludeWords $CountWords -IncludeBytes $CountBytes)
        }
        catch {
            $hadError = $true
            Write-PsCompatError -Command 'wc' -Message ("cannot open '{0}' for reading: {1}" -f $currentPath, $_.Exception.Message)
        }
    }

    if ($Path.Count -gt 1) {
        Write-Output (Format-WcOutput -Metrics $runningTotals -Label 'total' -UseDefaultSet $useDefaultSet -IncludeLines $CountLines -IncludeWords $CountWords -IncludeBytes $CountBytes)
    }

    if ($hadError) {
        Exit-PsCompat -Code 1
    }

    Exit-PsCompat -Code 0
}

if ($receivedPipelineInput) {
    $lines = Get-PsCompatBufferedLines -Buffer $pipelineBuffer
    $text = [string]::Join("`n", $lines)

    if ($lines.Length -gt 0) {
        $text += "`n"
    }

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    $metrics = Get-WcMetricsFromBytes -Bytes $bytes
    Write-Output (Format-WcOutput -Metrics $metrics -Label $null -UseDefaultSet $useDefaultSet -IncludeLines $CountLines -IncludeWords $CountWords -IncludeBytes $CountBytes)
}

Exit-PsCompat -Code 0
