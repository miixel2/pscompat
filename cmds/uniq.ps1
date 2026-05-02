#Requires -Version 5.1
<#
.SYNOPSIS
    Emulates a scoped subset of the Linux `uniq` command.

.DESCRIPTION
    Filters adjacent duplicate lines from a file or stdin-like pipeline input.
    The current MVP supports default unique-run output, `-c`, `-d`, `-u`, and
    `-i`.

    Behavioral differences from Linux:
    - Skip-field and skip-character modes are not implemented yet.
    - Output-file arguments are not implemented yet.

.PARAMETER Count
    Prefix lines by the number of occurrences in each adjacent run.

.PARAMETER Repeated
    Only print duplicated adjacent runs.

.PARAMETER UniqueOnly
    Only print non-duplicated adjacent runs.

.PARAMETER IgnoreCase
    Compare lines case-insensitively.

.PARAMETER Path
    Optional input file. If omitted, input is read from the pipeline.

.EXAMPLE
    # Linux:
    uniq -c .\sorted.txt

    # pscompat:
    .\cmds\uniq.ps1 -c .\sorted.txt

.EXAMPLE
    Get-Content .\sorted.txt | .\cmds\uniq.ps1 -d
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Alias('c')]
    [switch]$Count,

    [Alias('d')]
    [switch]$Repeated,

    [Alias('u')]
    [switch]$UniqueOnly,

    [Alias('i')]
    [switch]$IgnoreCase,

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

if ($Repeated -and $UniqueOnly) {
    Write-PsCompatError -Command 'uniq' -Message 'printing all duplicated and all unique lines is meaningless'
    Exit-PsCompat -Code 2
}

function Get-UniqKey {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [string]$Line,

        [Parameter(Mandatory)]
        [bool]$IgnoreCase
    )

    if ($IgnoreCase -and $null -ne $Line) {
        return $Line.ToLowerInvariant()
    }

    return $Line
}

function Write-UniqLines {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Lines,

        [Parameter(Mandatory)]
        [bool]$Count,

        [Parameter(Mandatory)]
        [bool]$Repeated,

        [Parameter(Mandatory)]
        [bool]$UniqueOnly,

        [Parameter(Mandatory)]
        [bool]$IgnoreCase
    )

    if ($Lines.Length -eq 0) {
        return
    }

    $currentLine = $Lines[0]
    $currentKey = Get-UniqKey -Line $currentLine -IgnoreCase $IgnoreCase
    $currentCount = 1

    for ($index = 1; $index -lt $Lines.Length; $index++) {
        $nextLine = $Lines[$index]
        $nextKey = Get-UniqKey -Line $nextLine -IgnoreCase $IgnoreCase

        if ($nextKey -eq $currentKey) {
            $currentCount++
            continue
        }

        Write-UniqRun -Line $currentLine -RunCount $currentCount -Count $Count -Repeated $Repeated -UniqueOnly $UniqueOnly
        $currentLine = $nextLine
        $currentKey = $nextKey
        $currentCount = 1
    }

    Write-UniqRun -Line $currentLine -RunCount $currentCount -Count $Count -Repeated $Repeated -UniqueOnly $UniqueOnly
}

function Write-UniqRun {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [string]$Line,

        [Parameter(Mandatory)]
        [int]$RunCount,

        [Parameter(Mandatory)]
        [bool]$Count,

        [Parameter(Mandatory)]
        [bool]$Repeated,

        [Parameter(Mandatory)]
        [bool]$UniqueOnly
    )

    if ($Repeated -and $RunCount -eq 1) {
        return
    }

    if ($UniqueOnly -and $RunCount -ne 1) {
        return
    }

    if ($Count) {
        Write-Output ("{0,7} {1}" -f $RunCount, $Line)
        return
    }

    Write-Output $Line
}

$pipelineBuffer = New-PsCompatLineBuffer
$receivedPipelineInput = $false

foreach ($pipelineItem in $input) {
    $receivedPipelineInput = $true
    Add-PsCompatPipelineLine -Buffer $pipelineBuffer -InputObject $pipelineItem
}

$hasPath = $null -ne $Path -and $Path.Count -gt 0

if ($hasPath) {
    if ($Path.Count -gt 1) {
        Write-PsCompatError -Command 'uniq' -Message 'extra operand is not supported yet'
        Exit-PsCompat -Code 2
    }

    try {
        $resolvedPath = Resolve-PsCompatPath -Path $Path[0]
        $lines = [System.IO.File]::ReadAllLines($resolvedPath)
        Write-UniqLines -Lines $lines -Count $Count -Repeated $Repeated -UniqueOnly $UniqueOnly -IgnoreCase $IgnoreCase
    }
    catch {
        Write-PsCompatError -Command 'uniq' -Message ("{0}: {1}" -f $Path[0], $_.Exception.Message)
        Exit-PsCompat -Code 1
    }

    Exit-PsCompat -Code 0
}

if ($receivedPipelineInput) {
    $lines = Get-PsCompatBufferedLines -Buffer $pipelineBuffer
    Write-UniqLines -Lines $lines -Count $Count -Repeated $Repeated -UniqueOnly $UniqueOnly -IgnoreCase $IgnoreCase
}

Exit-PsCompat -Code 0
