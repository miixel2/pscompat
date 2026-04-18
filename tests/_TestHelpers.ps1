#Requires -Version 5.1

Set-StrictMode -Version Latest

function New-PsCompatTestDirectory {
    [CmdletBinding()]
    param()

    $path = Join-Path ([System.IO.Path]::GetTempPath()) ("pscompat-tests-" + [System.Guid]::NewGuid().ToString("N"))
    [System.IO.Directory]::CreateDirectory($path) | Out-Null
    return $path
}

function Remove-PsCompatTestDirectory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
}

function ConvertTo-PsCompatSingleQuotedLiteral {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [string]$Value
    )

    if ($null -eq $Value) {
        return '$null'
    }

    return "'" + ($Value -replace "'", "''") + "'"
}

function ConvertTo-PsCompatNativeArgument {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [string]$Value
    )

    if ($null -eq $Value) {
        return '""'
    }

    if ($Value -notmatch '[\s"]') {
        return $Value
    }

    $escaped = $Value -replace '(\\*)"', '$1$1\"'
    $escaped = $escaped -replace '(\\+)$', '$1$1'

    return '"' + $escaped + '"'
}

function ConvertFrom-PsCompatCliXml {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [string]$Text
    )

    if ([string]::IsNullOrEmpty($Text)) {
        return $Text
    }

    $normalized = $Text

    if ($Text.StartsWith('#< CLIXML')) {
        try {
            $xmlText = $Text.Substring('#< CLIXML'.Length).Trim()
            $errorFragments = New-Object 'System.Collections.Generic.List[string]'
            $matches = [System.Text.RegularExpressions.Regex]::Matches($xmlText, '<S S="Error">(.*?)</S>', [System.Text.RegularExpressions.RegexOptions]::Singleline)

            foreach ($match in $matches) {
                $errorFragments.Add($match.Groups[1].Value) | Out-Null
            }

            if ($errorFragments.Count -gt 0) {
                $normalized = ($errorFragments.ToArray() -join '')
                $normalized = $normalized -replace '_x000D__x000A_', "`r`n"
            }
        }
        catch {
            $normalized = $Text
        }
    }

    $normalized = ($normalized -split "(`r`n|\n)At\s+", 2)[0]
    $normalized = ($normalized -split "(`r`n|\n)\s+\+", 2)[0]
    $normalized = ($normalized -split "(`r`n|\n)\s+CategoryInfo", 2)[0]
    $normalized = ($normalized -split "(`r`n|\n)\s+FullyQualifiedErrorId", 2)[0]
    $normalized = $normalized.Trim()
    $normalized = ($normalized -replace '^Write-PsCompatError\s*:\s*', '').Trim()

    if ($normalized -match '^[^:]+ : (.+)$') {
        $normalized = $Matches[1]
    }

    return (($normalized -replace '\s+', ' ').Trim())
}

function Invoke-PsCompatScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ScriptPath,

        [string[]]$ArgumentList = @(),

        [AllowNull()]
        [string]$StdIn
    )

    $resolvedScriptPath = [System.IO.Path]::GetFullPath($ScriptPath)
    $nativeArguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $resolvedScriptPath) + $ArgumentList
    $argumentText = ($nativeArguments | ForEach-Object {
        ConvertTo-PsCompatNativeArgument -Value ([string]$_)
    }) -join ' '

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "powershell.exe"
    $startInfo.Arguments = $argumentText
    $startInfo.RedirectStandardError = $true
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $process.Start() | Out-Null

    if ($null -ne $StdIn) {
        $process.StandardInput.Write($StdIn)
    }

    $process.StandardInput.Close()

    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = ConvertFrom-PsCompatCliXml -Text ($process.StandardError.ReadToEnd())

    $process.WaitForExit()

    [pscustomobject]@{
        ExitCode = $process.ExitCode
        StdOut   = $stdout
        StdErr   = $stderr
    }
}
