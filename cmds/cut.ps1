#Requires -Version 5.1
<#
.SYNOPSIS
    Emulates a scoped subset of the Linux `cut` command.

.DESCRIPTION
    Extracts delimiter-separated fields from files or stdin-like pipeline input.
    The current MVP supports `-d` and `-f` with comma-separated field lists and
    simple ranges.

    Behavioral differences from Linux:
    - Byte mode (`-b`) and character mode (`-c`) are not implemented yet.
    - `--complement` and output delimiter customization are not implemented yet.

.PARAMETER Delimiter
    Single-character field delimiter. Defaults to tab.

.PARAMETER Fields
    One-based field selection list, such as `1`, `1,3`, `2-4`, `2-`, or `-3`.

.PARAMETER Path
    One or more files to read. If omitted, input is read from the pipeline.

.EXAMPLE
    # Linux:
    cut -d , -f 1,3 .\data.csv

    # pscompat:
    .\cmds\cut.ps1 -d , -f 1,3 .\data.csv

.EXAMPLE
    Get-Content .\data.csv | .\cmds\cut.ps1 -d , -f 2
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Alias('d')]
    [string]$Delimiter = "`t",

    [Alias('f')]
    [string]$Fields,

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

if ([string]::IsNullOrEmpty($Fields)) {
    Write-PsCompatError -Command 'cut' -Message 'you must specify a list of fields'
    Exit-PsCompat -Code 2
}

if ($Delimiter.Length -ne 1) {
    Write-PsCompatError -Command 'cut' -Message 'the delimiter must be a single character'
    Exit-PsCompat -Code 2
}

function Get-CutFieldIndexes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FieldSpec,

        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$FieldCount
    )

    $selected = New-Object 'System.Collections.Generic.List[int]'
    $segments = $FieldSpec -split ','

    foreach ($segment in $segments) {
        $trimmed = $segment.Trim()

        if ($trimmed -match '^\d+$') {
            $index = [int]$trimmed

            if ($index -lt 1) {
                throw "fields are numbered from 1"
            }

            if ($index -le $FieldCount -and -not $selected.Contains($index - 1)) {
                $selected.Add($index - 1) | Out-Null
            }

            continue
        }

        if ($trimmed -match '^(\d*)-(\d*)$') {
            $startText = $Matches[1]
            $endText = $Matches[2]
            $start = if ([string]::IsNullOrEmpty($startText)) { 1 } else { [int]$startText }
            $end = if ([string]::IsNullOrEmpty($endText)) { $FieldCount } else { [int]$endText }

            if ($start -lt 1 -or $end -lt 1 -or $start -gt $end) {
                throw "invalid field range: '$trimmed'"
            }

            for ($fieldNumber = $start; $fieldNumber -le $end; $fieldNumber++) {
                if ($fieldNumber -le $FieldCount -and -not $selected.Contains($fieldNumber - 1)) {
                    $selected.Add($fieldNumber - 1) | Out-Null
                }
            }

            continue
        }

        throw "invalid field list: '$FieldSpec'"
    }

    return ,$selected.ToArray()
}

function Assert-CutFieldSpec {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FieldSpec
    )

    $segments = $FieldSpec -split ','

    foreach ($segment in $segments) {
        $trimmed = $segment.Trim()

        if ($trimmed -match '^\d+$') {
            if ([int]$trimmed -lt 1) {
                throw "fields are numbered from 1"
            }

            continue
        }

        if ($trimmed -match '^(\d*)-(\d*)$') {
            $startText = $Matches[1]
            $endText = $Matches[2]

            if ([string]::IsNullOrEmpty($startText) -and [string]::IsNullOrEmpty($endText)) {
                throw "invalid field range: '$trimmed'"
            }

            if (-not [string]::IsNullOrEmpty($startText) -and [int]$startText -lt 1) {
                throw "fields are numbered from 1"
            }

            if (-not [string]::IsNullOrEmpty($endText) -and [int]$endText -lt 1) {
                throw "fields are numbered from 1"
            }

            if (-not [string]::IsNullOrEmpty($startText) -and -not [string]::IsNullOrEmpty($endText) -and [int]$startText -gt [int]$endText) {
                throw "invalid field range: '$trimmed'"
            }

            continue
        }

        throw "invalid field list: '$FieldSpec'"
    }
}

function Write-CutLines {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Lines,

        [Parameter(Mandatory)]
        [string]$Delimiter,

        [Parameter(Mandatory)]
        [string]$Fields
    )

    foreach ($line in $Lines) {
        if (-not $line.Contains($Delimiter)) {
            Write-Output $line
            continue
        }

        $parts = $line.Split([char]$Delimiter)
        $indexes = Get-CutFieldIndexes -FieldSpec $Fields -FieldCount $parts.Length
        $selectedParts = foreach ($index in $indexes) {
            $parts[$index]
        }

        Write-Output ($selectedParts -join $Delimiter)
    }
}

try {
    Assert-CutFieldSpec -FieldSpec $Fields
}
catch {
    Write-PsCompatError -Command 'cut' -Message $_.Exception.Message
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

    foreach ($currentPath in $Path) {
        try {
            $resolvedPath = Resolve-PsCompatPath -Path $currentPath
            $lines = [System.IO.File]::ReadAllLines($resolvedPath)
            Write-CutLines -Lines $lines -Delimiter $Delimiter -Fields $Fields
        }
        catch {
            $hadError = $true
            Write-PsCompatError -Command 'cut' -Message ("{0}: {1}" -f $currentPath, $_.Exception.Message)
        }
    }

    if ($hadError) {
        Exit-PsCompat -Code 1
    }

    Exit-PsCompat -Code 0
}

if ($receivedPipelineInput) {
    $lines = Get-PsCompatBufferedLines -Buffer $pipelineBuffer
    Write-CutLines -Lines $lines -Delimiter $Delimiter -Fields $Fields
}

Exit-PsCompat -Code 0
