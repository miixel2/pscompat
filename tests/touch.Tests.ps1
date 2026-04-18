#Requires -Version 5.1

Describe 'touch.ps1' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
        $TouchScript = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\cmds\touch.ps1'))
    }

    BeforeEach {
        $TestDirectory = New-PsCompatTestDirectory
    }

    AfterEach {
        Remove-PsCompatTestDirectory -Path $TestDirectory
    }

    It 'creates a file when the path does not exist' {
        $targetPath = Join-Path $TestDirectory 'new-file.txt'

        $result = Invoke-PsCompatScript -ScriptPath $TouchScript -ArgumentList @($targetPath)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        (Test-Path -LiteralPath $targetPath) | Should -BeTrue
    }

    It 'updates timestamps when the target already exists' {
        $targetPath = Join-Path $TestDirectory 'existing.txt'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value 'seed'

        $itemBefore = Get-Item -LiteralPath $targetPath
        $baseline = (Get-Date).AddMinutes(-10)
        $itemBefore.LastAccessTime = $baseline
        $itemBefore.LastWriteTime = $baseline

        Start-Sleep -Milliseconds 1200

        $result = Invoke-PsCompatScript -ScriptPath $TouchScript -ArgumentList @($targetPath)
        $itemAfter = Get-Item -LiteralPath $targetPath

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $itemAfter.LastWriteTime | Should -BeGreaterThan $baseline
        $itemAfter.LastAccessTime | Should -BeGreaterThan $baseline
    }

    It 'returns exit code 2 when no path is provided' {
        $result = Invoke-PsCompatScript -ScriptPath $TouchScript

        $result.ExitCode | Should -Be 2
        $result.StdErr | Should -Match 'missing file operand'
    }

    It 'returns exit code 1 when the parent directory is missing' {
        $targetPath = Join-Path (Join-Path $TestDirectory 'missing-parent') 'new-file.txt'

        $result = Invoke-PsCompatScript -ScriptPath $TouchScript -ArgumentList @($targetPath)

        $result.ExitCode | Should -Be 1
        $result.StdErr | Should -Match "cannot touch"
        (Test-Path -LiteralPath $targetPath) | Should -BeFalse
    }

    It 'supports -c without creating a new file' {
        $targetPath = Join-Path $TestDirectory 'skip-create.txt'

        $result = Invoke-PsCompatScript -ScriptPath $TouchScript -ArgumentList @('-c', $targetPath)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        (Test-Path -LiteralPath $targetPath) | Should -BeFalse
    }
}
