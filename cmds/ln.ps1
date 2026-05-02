#Requires -Version 5.1
<#
.SYNOPSIS
    Emulates a scoped subset of the Linux `ln` command.

.DESCRIPTION
    Creates hard links by default and symbolic links when `-s` is provided.

    Behavioral differences from Linux:
    - This MVP supports a single `TARGET LINK_NAME` form only.
    - Windows link creation depends on filesystem capabilities and privileges.
    - Directory hard links are not supported.

.PARAMETER Symbolic
    Create a symbolic link instead of a hard link.

.PARAMETER Force
    Remove an existing destination path before creating the link.

.PARAMETER Path
    Positional operands in `TARGET LINK_NAME` order.

.EXAMPLE
    # Linux:
    ln .\source.txt .\copy-link.txt

    # pscompat:
    .\cmds\ln.ps1 .\source.txt .\copy-link.txt

.EXAMPLE
    .\cmds\ln.ps1 -s .\target.txt .\symlink.txt
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Alias('s')]
    [switch]$Symbolic,

    [Alias('f')]
    [switch]$Force,

    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Path
)

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
. (Join-Path (Join-Path $repoRoot 'lib') 'common.ps1')

$ErrorActionPreference = 'Stop'

if ($null -eq $Path -or $Path.Count -lt 2) {
    Write-PsCompatError -Command 'ln' -Message 'missing file operand'
    Exit-PsCompat -Code 2
}

if ($Path.Count -gt 2) {
    Write-PsCompatError -Command 'ln' -Message 'extra operand'
    Exit-PsCompat -Code 2
}

$targetInput = $Path[0]
$linkInput = $Path[1]

try {
    $targetPath = Resolve-PsCompatPath -Path $targetInput -AllowMissing
    $linkPath = Resolve-PsCompatPath -Path $linkInput -AllowMissing

    if (-not (Test-Path -LiteralPath $targetPath)) {
        Write-PsCompatError -Command 'ln' -Message ("failed to access '{0}': No such file or directory" -f $targetInput)
        Exit-PsCompat -Code 1
    }

    if (Test-Path -LiteralPath $linkPath) {
        if (-not $Force) {
            Write-PsCompatError -Command 'ln' -Message ("failed to create link '{0}': File exists" -f $linkInput)
            Exit-PsCompat -Code 1
        }

        if ($PSCmdlet.ShouldProcess($linkPath, 'remove existing destination')) {
            Remove-Item -LiteralPath $linkPath -Force -Recurse -ErrorAction Stop
        }
    }

    $itemType = if ($Symbolic) { 'SymbolicLink' } else { 'HardLink' }
    if ($PSCmdlet.ShouldProcess($linkPath, "create $itemType to $targetPath")) {
        New-Item -ItemType $itemType -Path $linkPath -Target $targetPath -ErrorAction Stop | Out-Null
    }

    Exit-PsCompat -Code 0
}
catch {
    Write-PsCompatError -Command 'ln' -Message ("failed to create link '{0}': {1}" -f $linkInput, $_.Exception.Message)
    Exit-PsCompat -Code 1
}
