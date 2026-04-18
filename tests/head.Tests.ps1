#Requires -Version 5.1

Describe 'head.ps1' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
        $HeadScript = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\cmds\head.ps1'))
    }

    BeforeEach {
        $TestDirectory = New-PsCompatTestDirectory
    }

    AfterEach {
        Remove-PsCompatTestDirectory -Path $TestDirectory
    }

    It 'writes the first 10 lines by default from a file' {
        $targetPath = Join-Path $TestDirectory 'sample.txt'
        $content = 1..12 | ForEach-Object { "line$_" }
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value $content

        $result = Invoke-PsCompatScript -ScriptPath $HeadScript -ArgumentList @($targetPath)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        ($result.StdOut -split "`r?`n" | Where-Object { $_ -ne '' }).Count | Should -Be 10
        $result.StdOut | Should -Match 'line1'
        $result.StdOut | Should -Match 'line10'
    }

    It 'supports -n for explicit line counts' {
        $targetPath = Join-Path $TestDirectory 'sample.txt'
        $content = 1..5 | ForEach-Object { "line$_" }
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value $content

        $result = Invoke-PsCompatScript -ScriptPath $HeadScript -ArgumentList @('-n', '3', $targetPath)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $result.StdOut | Should -Be "line1`r`nline2`r`nline3`r`n"
    }

    It 'supports pipeline input when no file path is supplied' {
        . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
        $stdin = "line1`nline2`nline3`nline4`n"

        $result = Invoke-PsCompatScript -ScriptPath $HeadScript -ArgumentList @('-n', '2') -StdIn $stdin

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $result.StdOut | Should -Be "line1`r`nline2`r`n"
    }

    It 'returns exit code 1 for a missing file' {
        $targetPath = Join-Path $TestDirectory 'missing.txt'

        $result = Invoke-PsCompatScript -ScriptPath $HeadScript -ArgumentList @($targetPath)

        $result.ExitCode | Should -Be 1
        $result.StdErr | Should -Match 'cannot open'
    }

    It 'returns exit code 2 for a negative line count' {
        $targetPath = Join-Path $TestDirectory 'sample.txt'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value @('line1')

        $result = Invoke-PsCompatScript -ScriptPath $HeadScript -ArgumentList @('-n', '-1', $targetPath)

        $result.ExitCode | Should -Be 2
        $result.StdErr | Should -Match 'invalid number of lines'
    }

    It 'writes Linux-style headers when multiple files are supplied' {
        $firstPath = Join-Path $TestDirectory 'first.txt'
        $secondPath = Join-Path $TestDirectory 'second.txt'

        Set-Content -LiteralPath $firstPath -Encoding ASCII -Value @('a1', 'a2', 'a3')
        Set-Content -LiteralPath $secondPath -Encoding ASCII -Value @('b1', 'b2', 'b3')

        $result = Invoke-PsCompatScript -ScriptPath $HeadScript -ArgumentList @('-n', '1', $firstPath, $secondPath)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $result.StdOut | Should -Match '==> '
        $result.StdOut | Should -Match 'a1'
        $result.StdOut | Should -Match 'b1'
    }
}
