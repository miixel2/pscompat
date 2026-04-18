#Requires -Version 5.1
<#
.SYNOPSIS
    Emulates a scoped subset of the Linux `which` command.

.DESCRIPTION
    Resolves command names against the current PATH and prints the first
    matching executable or external script for each name supplied.

    Behavioral differences from Linux:
    - `-a` is not implemented yet.
    - Resolution is limited to Windows applications and external scripts;
      PowerShell aliases and functions are intentionally excluded.

.PARAMETER Name
    One or more command names to resolve.

.EXAMPLE
    # Linux:
    which python

    # pscompat:
    .\cmds\which.ps1 python
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Name
)

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
. (Join-Path (Join-Path $repoRoot 'lib') 'common.ps1')

$ErrorActionPreference = 'Stop'

if ($null -eq $Name -or $Name.Count -eq 0) {
    Write-PsCompatError -Command 'which' -Message 'missing command name'
    Exit-PsCompat -Code 2
}

$hadError = $false

foreach ($currentName in $Name) {
    try {
        $commandInfo = Get-Command -Name $currentName -CommandType Application,ExternalScript -ErrorAction Stop | Select-Object -First 1
        Write-Output $commandInfo.Source
    }
    catch {
        $hadError = $true
        Write-PsCompatError -Command 'which' -Message ("no {0} in PATH" -f $currentName)
    }
}

if ($hadError) {
    Exit-PsCompat -Code 1
}

Exit-PsCompat -Code 0
