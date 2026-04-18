#Requires -Version 5.1

Set-StrictMode -Version Latest

function Resolve-PsCompatPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [switch]$AllowMissing
    )

    $expandedPath = [Environment]::ExpandEnvironmentVariables($Path)

    if ($AllowMissing) {
        return [System.IO.Path]::GetFullPath($expandedPath)
    }

    return (Resolve-Path -LiteralPath $expandedPath -ErrorAction Stop).ProviderPath
}

function Write-PsCompatError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Command,

        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Error -Message ("{0}: {1}" -f $Command, $Message) -ErrorAction Continue
}

function Exit-PsCompat {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, 255)]
        [int]$Code
    )

    $global:LASTEXITCODE = $Code
    $script:PsCompatLastExitCode = $Code

    $suppressExit = Get-Variable -Name 'PsCompatSuppressExit' -Scope Script -ErrorAction SilentlyContinue
    if ($null -ne $suppressExit -and $suppressExit.Value) {
        return $Code
    }

    exit $Code
}
