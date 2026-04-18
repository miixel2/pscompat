#Requires -Version 5.1

Describe 'wc.ps1' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
        $WcScript = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\cmds\wc.ps1'))
    }

    BeforeEach {
        $TestDirectory = New-PsCompatTestDirectory
    }

    AfterEach {
        Remove-PsCompatTestDirectory -Path $TestDirectory
    }

    It 'writes default line, word, and byte counts for a file' {
        $targetPath = Join-Path $TestDirectory 'sample.txt'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -NoNewline -Value "one two`nthree four`n"

        $result = Invoke-PsCompatScript -ScriptPath $WcScript -ArgumentList @($targetPath)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $result.StdOut | Should -Match '^2 4 19 '
    }

    It 'supports explicit -l, -w, and -c output' {
        $targetPath = Join-Path $TestDirectory 'sample.txt'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -NoNewline -Value "one two`nthree four`n"

        $result = Invoke-PsCompatScript -ScriptPath $WcScript -ArgumentList @('-l', '-w', '-c', $targetPath)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $result.StdOut | Should -Be "2 4 19 $targetPath`r`n"
    }

    It 'supports pipeline input when no file path is supplied' {
        $stdin = "one two`nthree four`n"

        $result = Invoke-PsCompatScript -ScriptPath $WcScript -ArgumentList @('-l') -StdIn $stdin

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $result.StdOut | Should -Be "2`r`n"
    }

    It 'returns exit code 1 for a missing file' {
        $targetPath = Join-Path $TestDirectory 'missing.txt'

        $result = Invoke-PsCompatScript -ScriptPath $WcScript -ArgumentList @($targetPath)

        $result.ExitCode | Should -Be 1
        $result.StdErr | Should -Match 'cannot open'
    }

    It 'writes a total row when multiple files are supplied' {
        $firstPath = Join-Path $TestDirectory 'first.txt'
        $secondPath = Join-Path $TestDirectory 'second.txt'

        Set-Content -LiteralPath $firstPath -Encoding ASCII -NoNewline -Value "a b`n"
        Set-Content -LiteralPath $secondPath -Encoding ASCII -NoNewline -Value "c d`ne f`n"

        $result = Invoke-PsCompatScript -ScriptPath $WcScript -ArgumentList @($firstPath, $secondPath)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $result.StdOut | Should -Match 'total'
    }
}
