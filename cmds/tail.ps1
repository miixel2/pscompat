#Requires -Version 5.1
<#
.SYNOPSIS
    Emulates a scoped subset of the Linux `tail` command.

.DESCRIPTION
    Writes the last lines from a file or stdin-like pipeline input.
    The current MVP supports default 10-line behavior, `-n`, file input,
    pipeline input, and multiple file headers.

    Behavioral differences from Linux:
    - Follow mode (`-f`) is not implemented yet.
    - Byte-count mode (`-c`) is not implemented yet.
    - Relative forms such as `-n +5` are not implemented yet.

.PARAMETER LineCount
    Number of lines to print. Defaults to 10.

.PARAMETER Path
    One or more files to read.

.PARAMETER InputObject
    Pipeline text input when no file path is supplied.

.EXAMPLE
    # Linux:
    tail -n 5 .\app.log

    # pscompat:
    .\cmds\tail.ps1 -n 5 .\app.log

.EXAMPLE
    Get-Content .\app.log | .\cmds\tail.ps1 -n 5
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
    Write-PsCompatError -Command 'tail' -Message ("invalid number of lines: '{0}'" -f $LineCount)
    Exit-PsCompat -Code 2
}

function Write-TailLines {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]$Lines,

        [Parameter(Mandatory)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Count
    )

    if ($Count -eq 0 -or $Lines.Length -eq 0) {
        return
    }

    $startIndex = [System.Math]::Max(0, $Lines.Length - $Count)

    for ($lineIndex = $startIndex; $lineIndex -lt $Lines.Length; $lineIndex++) {
        Write-Output $Lines[$lineIndex]
    }
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
            Write-TailLines -Lines $lines -Count $LineCount
        }
        catch {
            $hadError = $true
            Write-PsCompatError -Command 'tail' -Message ("cannot open '{0}' for reading: {1}" -f $currentPath, $_.Exception.Message)
        }
    }

    if ($hadError) {
        Exit-PsCompat -Code 1
    }

    Exit-PsCompat -Code 0
}

if ($receivedPipelineInput) {
    $lines = Get-PsCompatBufferedLines -Buffer $pipelineBuffer
    Write-TailLines -Lines $lines -Count $LineCount
}

Exit-PsCompat -Code 0
