#Requires -Version 5.1

Describe 'which.ps1' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
        $WhichScript = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\cmds\which.ps1'))
    }

    BeforeEach {
        $TestDirectory = New-PsCompatTestDirectory
    }

    AfterEach {
        Remove-PsCompatTestDirectory -Path $TestDirectory
    }

    It 'resolves the first matching command from PATH' {
        $binDirectory = Join-Path $TestDirectory 'bin'
        New-Item -ItemType Directory -Path $binDirectory | Out-Null

        $commandPath = Join-Path $binDirectory 'fake-tool.cmd'
        Set-Content -LiteralPath $commandPath -Encoding ASCII -NoNewline -Value "@echo off`r`n"

        $result = Invoke-PsCompatScript -ScriptPath $WhichScript -ArgumentList @('fake-tool') -EnvironmentVariables @{
            PATH = $binDirectory
        }

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $result.StdOut | Should -Be "$commandPath`r`n"
    }

    It 'returns exit code 1 when a command is missing' {
        $result = Invoke-PsCompatScript -ScriptPath $WhichScript -ArgumentList @('definitely-missing-command') -EnvironmentVariables @{
            PATH = $TestDirectory
        }

        $result.ExitCode | Should -Be 1
        $result.StdErr | Should -Match 'no definitely-missing-command in PATH'
    }

    It 'returns exit code 2 when no command name is provided' {
        $result = Invoke-PsCompatScript -ScriptPath $WhichScript

        $result.ExitCode | Should -Be 2
        $result.StdErr | Should -Match 'missing command name'
    }

    It 'processes multiple names and keeps going after a miss' {
        $binDirectory = Join-Path $TestDirectory 'bin'
        New-Item -ItemType Directory -Path $binDirectory | Out-Null

        $commandPath = Join-Path $binDirectory 'fake-tool.cmd'
        Set-Content -LiteralPath $commandPath -Encoding ASCII -NoNewline -Value "@echo off`r`n"

        $result = Invoke-PsCompatScript -ScriptPath $WhichScript -ArgumentList @('fake-tool', 'missing-tool') -EnvironmentVariables @{
            PATH = $binDirectory
        }

        $result.ExitCode | Should -Be 1
        $result.StdOut | Should -Be "$commandPath`r`n"
        $result.StdErr | Should -Match 'no missing-tool in PATH'
    }
}
