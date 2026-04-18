#Requires -Version 5.1
<#
.SYNOPSIS
    Emulates a scoped subset of the Linux `touch` command.

.DESCRIPTION
    Creates a file when it does not exist, or updates the access and modification
    timestamps when it does. The current MVP supports default behavior plus `-c`,
    GNU-style `--no-create`, and the PowerShell-friendly `-NoCreate` form.

    Behavioral differences from Linux:
    - Timestamp source flags such as `-a`, `-m`, `-d`, `-t`, and `-r` are not implemented yet.
    - Timestamp precision follows Windows and .NET filesystem behavior.

.PARAMETER Path
    One or more file or directory paths to update.

.PARAMETER NoCreate
    Do not create files that do not already exist.

.EXAMPLE
    # Linux:
    touch .\notes.txt

    # pscompat:
    .\cmds\touch.ps1 .\notes.txt

.EXAMPLE
    .\cmds\touch.ps1 -c .\already-known-path.txt
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Alias('c', 'no-create')]
    [switch]$NoCreate,

    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Path
)

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
. (Join-Path (Join-Path $repoRoot 'lib') 'common.ps1')

$ErrorActionPreference = 'Stop'

if ($null -eq $Path -or $Path.Count -eq 0) {
    Write-PsCompatError -Command 'touch' -Message 'missing file operand'
    Exit-PsCompat -Code 2
}

$hadError = $false

foreach ($currentPath in $Path) {
    try {
        $resolvedTarget = Resolve-PsCompatPath -Path $currentPath -AllowMissing
        $now = Get-Date

        if (Test-Path -LiteralPath $resolvedTarget) {
            if ($PSCmdlet.ShouldProcess($resolvedTarget, 'update timestamps')) {
                $item = Get-Item -LiteralPath $resolvedTarget -ErrorAction Stop
                $item.LastAccessTime = $now
                $item.LastWriteTime = $now
            }

            continue
        }

        if ($NoCreate) {
            continue
        }

        $parentPath = Split-Path -Path $resolvedTarget -Parent
        if ($parentPath -and -not (Test-Path -LiteralPath $parentPath)) {
            throw [System.IO.DirectoryNotFoundException]::new('No such file or directory')
        }

        if ($PSCmdlet.ShouldProcess($resolvedTarget, 'create file')) {
            $stream = [System.IO.File]::Open($resolvedTarget, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite)

            try {
            }
            finally {
                $stream.Dispose()
            }

            $item = Get-Item -LiteralPath $resolvedTarget -ErrorAction Stop
            $item.LastAccessTime = $now
            $item.LastWriteTime = $now
        }
    }
    catch {
        $hadError = $true
        Write-PsCompatError -Command 'touch' -Message ("cannot touch '{0}': {1}" -f $currentPath, $_.Exception.Message)
    }
}

if ($hadError) {
    Exit-PsCompat -Code 1
}

Exit-PsCompat -Code 0
