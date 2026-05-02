#Requires -Version 5.1
<#
.SYNOPSIS
    Emulates a scoped subset of the Linux `grep` command.

.DESCRIPTION
    Searches text from files or stdin-like pipeline input using .NET regular
    expressions. The current MVP supports pattern search, file input, pipeline
    input, multi-file filename prefixes, `-i`, `-n`, and `-v`.

    Behavioral differences from Linux:
    - Pattern syntax follows .NET regex rather than GNU grep exactly.
    - Recursive mode (`-r`) and fixed-string mode (`-F`) are not implemented yet.
    - Binary file handling is not implemented yet.

.PARAMETER IgnoreCase
    Match without case sensitivity.

.PARAMETER LineNumber
    Prefix selected lines with one-based line numbers.

.PARAMETER InvertMatch
    Select non-matching lines.

.PARAMETER Pattern
    Regular expression pattern to search for.

.PARAMETER Path
    One or more files to read. If omitted, input is read from the pipeline.

.EXAMPLE
    # Linux:
    grep -n ERROR .\app.log

    # pscompat:
    .\cmds\grep.ps1 -n ERROR .\app.log

.EXAMPLE
    Get-Content .\app.log | .\cmds\grep.ps1 -i error
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Alias('i')]
    [switch]$IgnoreCase,

    [Alias('n')]
    [switch]$LineNumber,

    [Alias('v')]
    [switch]$InvertMatch,

    [Parameter(Position = 0)]
    [string]$Pattern,

    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$Path,

    [Parameter(ValueFromPipeline = $true)]
    [AllowNull()]
    [object]$InputObject
)

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
. (Join-Path (Join-Path $repoRoot 'lib') 'common.ps1')
. (Join-Path (Join-Path $repoRoot 'lib') 'pipeline.ps1')

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrEmpty($Pattern)) {
    Write-PsCompatError -Command 'grep' -Message 'missing pattern'
    Exit-PsCompat -Code 2
}

$regexOptions = [System.Text.RegularExpressions.RegexOptions]::None
if ($IgnoreCase) {
    $regexOptions = $regexOptions -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
}

try {
    $regex = New-Object System.Text.RegularExpressions.Regex($Pattern, $regexOptions)
}
catch {
    Write-PsCompatError -Command 'grep' -Message ("invalid pattern: {0}" -f $_.Exception.Message)
    Exit-PsCompat -Code 2
}

function Write-GrepMatches {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Lines,

        [AllowNull()]
        [string]$Label,

        [Parameter(Mandatory)]
        [bool]$ShowLabel,

        [Parameter(Mandatory)]
        [System.Text.RegularExpressions.Regex]$Regex,

        [Parameter(Mandatory)]
        [bool]$ShowLineNumber,

        [Parameter(Mandatory)]
        [bool]$Invert
    )

    $matchedAny = $false
    $selectedLines = New-Object 'System.Collections.Generic.List[string]'

    for ($index = 0; $index -lt $Lines.Length; $index++) {
        $line = $Lines[$index]
        $isMatch = $Regex.IsMatch($line)

        if ($Invert) {
            $isMatch = -not $isMatch
        }

        if (-not $isMatch) {
            continue
        }

        $matchedAny = $true
        $prefix = ''

        if ($ShowLabel) {
            $prefix += ('{0}:' -f $Label)
        }

        if ($ShowLineNumber) {
            $prefix += ('{0}:' -f ($index + 1))
        }

        $selectedLines.Add($prefix + $line) | Out-Null
    }

    [pscustomobject]@{
        Matched = $matchedAny
        Lines   = $selectedLines.ToArray()
    }
}

$pipelineBuffer = New-PsCompatLineBuffer
$receivedPipelineInput = $false

foreach ($pipelineItem in $input) {
    $receivedPipelineInput = $true
    Add-PsCompatPipelineLine -Buffer $pipelineBuffer -InputObject $pipelineItem
}

$hasPath = $null -ne $Path -and $Path.Count -gt 0
$hadError = $false
$hadMatch = $false

if ($hasPath) {
    $showLabel = $Path.Count -gt 1

    foreach ($currentPath in $Path) {
        try {
            $resolvedPath = Resolve-PsCompatPath -Path $currentPath
            $lines = [System.IO.File]::ReadAllLines($resolvedPath)
            $result = Write-GrepMatches -Lines $lines -Label $currentPath -ShowLabel $showLabel -Regex $regex -ShowLineNumber $LineNumber -Invert $InvertMatch

            foreach ($selectedLine in $result.Lines) {
                Write-Output $selectedLine
            }

            $hadMatch = $hadMatch -or $result.Matched
        }
        catch {
            $hadError = $true
            Write-PsCompatError -Command 'grep' -Message ("{0}: {1}" -f $currentPath, $_.Exception.Message)
        }
    }

    if ($hadError) {
        Exit-PsCompat -Code 2
    }

    if ($hadMatch) {
        Exit-PsCompat -Code 0
    }

    Exit-PsCompat -Code 1
}

if ($receivedPipelineInput) {
    $lines = Get-PsCompatBufferedLines -Buffer $pipelineBuffer
    $result = Write-GrepMatches -Lines $lines -Label $null -ShowLabel $false -Regex $regex -ShowLineNumber $LineNumber -Invert $InvertMatch

    foreach ($selectedLine in $result.Lines) {
        Write-Output $selectedLine
    }

    $hadMatch = $result.Matched
}

if ($hadMatch) {
    Exit-PsCompat -Code 0
}

Exit-PsCompat -Code 1
