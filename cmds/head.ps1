#Requires -Version 5.1
<#
.SYNOPSIS
    Emulates a scoped subset of the Linux `head` command.

.DESCRIPTION
    Writes the first lines from a file or stdin-like pipeline input.
    The current MVP supports default 10-line behavior, `-n`, file input,
    pipeline input, and multiple file headers.

    Behavioral differences from Linux:
    - Negative counts such as `-n -5` are not implemented.
    - Byte-count mode (`-c`) is not implemented yet.

.PARAMETER LineCount
    Number of lines to print. Defaults to 10.

.PARAMETER Path
    One or more files to read.

.PARAMETER InputObject
    Pipeline text input when no file path is supplied.

.EXAMPLE
    # Linux:
    head -n 5 .\app.log

    # pscompat:
    .\cmds\head.ps1 -n 5 .\app.log

.EXAMPLE
    Get-Content .\app.log | .\cmds\head.ps1 -n 5
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Alias('n', 'Lines')]
    [int]$LineCount = 10,

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

if ($LineCount -lt 0) {
    Write-PsCompatError -Command 'head' -Message ("invalid number of lines: '{0}'" -f $LineCount)
    Exit-PsCompat -Code 2
}

$pipelineBuffer = New-PsCompatLineBuffer
$receivedPipelineInput = $false

foreach ($pipelineItem in $input) {
    $receivedPipelineInput = $true
    Add-PsCompatPipelineLine -Buffer $pipelineBuffer -InputObject $pipelineItem
}

$hasPath = $null -ne $Path -and $Path.Count -gt 0

if ($hasPath) {
    $hadError = $false

    for ($index = 0; $index -lt $Path.Count; $index++) {
        $currentPath = $Path[$index]

        try {
            $resolvedPath = Resolve-PsCompatPath -Path $currentPath

            if ($Path.Count -gt 1) {
                if ($index -gt 0) {
                    Write-Output ''
                }

                Write-Output ("==> {0} <==" -f $currentPath)
            }

            $lines = [System.IO.File]::ReadAllLines($resolvedPath)
            $upperBound = [System.Math]::Min($LineCount, $lines.Length)

            for ($lineIndex = 0; $lineIndex -lt $upperBound; $lineIndex++) {
                Write-Output $lines[$lineIndex]
            }
        }
        catch {
            $hadError = $true
            Write-PsCompatError -Command 'head' -Message ("cannot open '{0}' for reading: {1}" -f $currentPath, $_.Exception.Message)
        }
    }

    if ($hadError) {
        Exit-PsCompat -Code 1
    }

    Exit-PsCompat -Code 0
}

if ($receivedPipelineInput) {
    $lines = Get-PsCompatBufferedLines -Buffer $pipelineBuffer
    $upperBound = [System.Math]::Min($LineCount, $lines.Length)

    for ($lineIndex = 0; $lineIndex -lt $upperBound; $lineIndex++) {
        Write-Output $lines[$lineIndex]
    }
}

Exit-PsCompat -Code 0
