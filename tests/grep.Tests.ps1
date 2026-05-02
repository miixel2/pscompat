#Requires -Version 5.1

Describe 'grep.ps1' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
        $GrepScript = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\cmds\grep.ps1'))
    }

    BeforeEach {
        $TestDirectory = New-PsCompatTestDirectory
    }

    AfterEach {
        Remove-PsCompatTestDirectory -Path $TestDirectory
    }

    It 'selects matching lines from a file' {
        $targetPath = Join-Path $TestDirectory 'sample.txt'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value @('info', 'ERROR one', 'debug')

        $result = Invoke-PsCompatScript -ScriptPath $GrepScript -ArgumentList @('ERROR', $targetPath)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $result.StdOut | Should -Be "ERROR one`r`n"
    }

    It 'returns exit code 1 when no lines match' {
        $targetPath = Join-Path $TestDirectory 'sample.txt'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value @('info', 'debug')

        $result = Invoke-PsCompatScript -ScriptPath $GrepScript -ArgumentList @('ERROR', $targetPath)

        $result.ExitCode | Should -Be 1
        $result.StdOut | Should -Be ''
        $result.StdErr | Should -Be ''
    }

    It 'supports -i, -n, and -v' {
        $targetPath = Join-Path $TestDirectory 'sample.txt'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value @('info', 'error one', 'debug')

        $ignoreCaseResult = Invoke-PsCompatScript -ScriptPath $GrepScript -ArgumentList @('-i', 'ERROR', $targetPath)
        $lineNumberResult = Invoke-PsCompatScript -ScriptPath $GrepScript -ArgumentList @('-n', 'error', $targetPath)
        $invertResult = Invoke-PsCompatScript -ScriptPath $GrepScript -ArgumentList @('-v', 'error', $targetPath)

        $ignoreCaseResult.StdOut | Should -Be "error one`r`n"
        $lineNumberResult.StdOut | Should -Be "2:error one`r`n"
        $invertResult.StdOut | Should -Be "info`r`ndebug`r`n"
    }

    It 'supports pipeline input' {
        $stdin = "alpha`nbeta`ngamma`n"

        $result = Invoke-PsCompatScript -ScriptPath $GrepScript -ArgumentList @('a$') -StdIn $stdin

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Be "alpha`r`nbeta`r`ngamma`r`n"
    }

    It 'prefixes filenames for multiple files' {
        $firstPath = Join-Path $TestDirectory 'first.txt'
        $secondPath = Join-Path $TestDirectory 'second.txt'

        Set-Content -LiteralPath $firstPath -Encoding ASCII -Value @('apple', 'pear')
        Set-Content -LiteralPath $secondPath -Encoding ASCII -Value @('grape', 'plum')

        $result = Invoke-PsCompatScript -ScriptPath $GrepScript -ArgumentList @('p', $firstPath, $secondPath)

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Match 'first.txt:apple'
        $result.StdOut | Should -Match 'second.txt:grape'
    }

    It 'returns exit code 2 for invalid usage and file errors' {
        $missingPattern = Invoke-PsCompatScript -ScriptPath $GrepScript
        $missingFile = Invoke-PsCompatScript -ScriptPath $GrepScript -ArgumentList @('x', (Join-Path $TestDirectory 'missing.txt'))
        $invalidRegex = Invoke-PsCompatScript -ScriptPath $GrepScript -ArgumentList @('[')

        $missingPattern.ExitCode | Should -Be 2
        $missingFile.ExitCode | Should -Be 2
        $invalidRegex.ExitCode | Should -Be 2
    }
}
