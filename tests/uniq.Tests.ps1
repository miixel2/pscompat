#Requires -Version 5.1

Describe 'uniq.ps1' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
        $UniqScript = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\cmds\uniq.ps1'))
    }

    BeforeEach {
        $TestDirectory = New-PsCompatTestDirectory
    }

    AfterEach {
        Remove-PsCompatTestDirectory -Path $TestDirectory
    }

    It 'collapses adjacent duplicate lines from a file' {
        $targetPath = Join-Path $TestDirectory 'sorted.txt'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value @('a', 'a', 'b', 'a')

        $result = Invoke-PsCompatScript -ScriptPath $UniqScript -ArgumentList @($targetPath)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $result.StdOut | Should -Be "a`r`nb`r`na`r`n"
    }

    It 'supports -c, -d, and -u' {
        $targetPath = Join-Path $TestDirectory 'sorted.txt'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value @('a', 'a', 'b', 'c', 'c')

        $countResult = Invoke-PsCompatScript -ScriptPath $UniqScript -ArgumentList @('-c', $targetPath)
        $repeatedResult = Invoke-PsCompatScript -ScriptPath $UniqScript -ArgumentList @('-d', $targetPath)
        $uniqueResult = Invoke-PsCompatScript -ScriptPath $UniqScript -ArgumentList @('-u', $targetPath)

        $countResult.StdOut | Should -Match '2 a'
        $repeatedResult.StdOut | Should -Be "a`r`nc`r`n"
        $uniqueResult.StdOut | Should -Be "b`r`n"
    }

    It 'supports -i for case-insensitive comparison' {
        $targetPath = Join-Path $TestDirectory 'sorted.txt'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value @('Alpha', 'alpha', 'beta')

        $result = Invoke-PsCompatScript -ScriptPath $UniqScript -ArgumentList @('-i', $targetPath)

        $result.StdOut | Should -Be "Alpha`r`nbeta`r`n"
    }

    It 'supports pipeline input' {
        $stdin = "a`na`nb`n"

        $result = Invoke-PsCompatScript -ScriptPath $UniqScript -StdIn $stdin

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Be "a`r`nb`r`n"
    }

    It 'returns exit code 1 for a missing file' {
        $targetPath = Join-Path $TestDirectory 'missing.txt'

        $result = Invoke-PsCompatScript -ScriptPath $UniqScript -ArgumentList @($targetPath)

        $result.ExitCode | Should -Be 1
        $result.StdErr | Should -Match 'uniq:'
    }

    It 'returns exit code 2 for unsupported usage' {
        $firstPath = Join-Path $TestDirectory 'first.txt'
        $secondPath = Join-Path $TestDirectory 'second.txt'
        Set-Content -LiteralPath $firstPath -Encoding ASCII -Value @('a')
        Set-Content -LiteralPath $secondPath -Encoding ASCII -Value @('b')

        $extraOperand = Invoke-PsCompatScript -ScriptPath $UniqScript -ArgumentList @($firstPath, $secondPath)
        $conflictingModes = Invoke-PsCompatScript -ScriptPath $UniqScript -ArgumentList @('-d', '-u', $firstPath)

        $extraOperand.ExitCode | Should -Be 2
        $conflictingModes.ExitCode | Should -Be 2
    }
}
