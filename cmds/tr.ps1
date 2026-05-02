#Requires -Version 5.1
<#
.SYNOPSIS
    Emulates a scoped subset of the Linux `tr` command.

.DESCRIPTION
    Translates or deletes characters from stdin-like pipeline input.
    The current MVP supports character translation, deletion with `-d`, simple
    ascending ranges such as `a-z`, and common escapes such as `\n` and `\t`.

    Behavioral differences from Linux:
    - Complement mode (`-c`) and squeeze mode (`-s`) are not implemented yet.
    - Character classes such as `[:lower:]` are not implemented yet.
    - Input is reconstructed from native PowerShell pipeline text.

.PARAMETER Delete
    Delete characters from Set1 instead of translating.

.PARAMETER Set1
    Source character set.

.PARAMETER Set2
    Replacement character set for translation mode.

.EXAMPLE
    # Linux:
    tr a-z A-Z

    # pscompat:
    Get-Content .\input.txt | .\cmds\tr.ps1 a-z A-Z

.EXAMPLE
    Get-Content .\input.txt | .\cmds\tr.ps1 -d 0-9
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Alias('d')]
    [switch]$Delete,

    [Parameter(Position = 0)]
    [string]$Set1,

    [Parameter(Position = 1)]
    [string]$Set2,

    [Parameter(ValueFromPipeline = $true)]
    [AllowNull()]
    [object]$InputObject
)

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
. (Join-Path (Join-Path $repoRoot 'lib') 'common.ps1')
. (Join-Path (Join-Path $repoRoot 'lib') 'pipeline.ps1')

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrEmpty($Set1)) {
    Write-PsCompatError -Command 'tr' -Message 'missing operand'
    Exit-PsCompat -Code 2
}

if (-not $Delete -and [string]::IsNullOrEmpty($Set2)) {
    Write-PsCompatError -Command 'tr' -Message 'missing operand after first set'
    Exit-PsCompat -Code 2
}

function ConvertFrom-TrEscape {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [char]$Character
    )

    switch ($Character) {
        'n' { return [char]10 }
        'r' { return [char]13 }
        't' { return [char]9 }
        '\' { return [char]'\' }
        default { return $Character }
    }
}

function Expand-TrSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Set
    )

    $characters = New-Object 'System.Collections.Generic.List[char]'
    $index = 0

    while ($index -lt $Set.Length) {
        $current = [char]$Set[$index]

        if ($current -eq '\') {
            if ($index + 1 -ge $Set.Length) {
                $characters.Add('\') | Out-Null
                $index++
                continue
            }

            $characters.Add((ConvertFrom-TrEscape -Character ([char]$Set[$index + 1]))) | Out-Null
            $index += 2
            continue
        }

        if ($index + 2 -lt $Set.Length -and $Set[$index + 1] -eq '-') {
            $rangeEnd = [char]$Set[$index + 2]
            $startCode = [int][char]$current
            $endCode = [int][char]$rangeEnd

            if ($startCode -le $endCode) {
                for ($code = $startCode; $code -le $endCode; $code++) {
                    $characters.Add([char]$code) | Out-Null
                }

                $index += 3
                continue
            }
        }

        $characters.Add($current) | Out-Null
        $index++
    }

    return ,$characters.ToArray()
}

$set1Chars = Expand-TrSet -Set $Set1
$set2Chars = if ($Delete) { @() } else { Expand-TrSet -Set $Set2 }

if ($set1Chars.Length -eq 0) {
    Write-PsCompatError -Command 'tr' -Message 'set1 must not be empty'
    Exit-PsCompat -Code 2
}

if (-not $Delete -and $set2Chars.Length -eq 0) {
    Write-PsCompatError -Command 'tr' -Message 'set2 must not be empty'
    Exit-PsCompat -Code 2
}

$pipelineBuffer = New-PsCompatLineBuffer
$receivedPipelineInput = $false

foreach ($pipelineItem in $input) {
    $receivedPipelineInput = $true
    Add-PsCompatPipelineLine -Buffer $pipelineBuffer -InputObject $pipelineItem
}

if (-not $receivedPipelineInput) {
    Exit-PsCompat -Code 0
}

$lines = Get-PsCompatBufferedLines -Buffer $pipelineBuffer
$text = [string]::Join("`n", $lines)

if ($lines.Length -gt 0) {
    $text += "`n"
}

$builder = New-Object System.Text.StringBuilder

for ($index = 0; $index -lt $text.Length; $index++) {
    $current = [char]$text[$index]
    $setIndex = [Array]::IndexOf($set1Chars, $current)

    if ($Delete) {
        if ($setIndex -lt 0) {
            [void]$builder.Append($current)
        }

        continue
    }

    if ($setIndex -lt 0) {
        [void]$builder.Append($current)
        continue
    }

    $replacementIndex = [System.Math]::Min($setIndex, $set2Chars.Length - 1)
    [void]$builder.Append($set2Chars[$replacementIndex])
}

[Console]::Out.Write($builder.ToString())
Exit-PsCompat -Code 0
