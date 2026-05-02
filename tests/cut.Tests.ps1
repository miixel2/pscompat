#Requires -Version 5.1

Describe 'cut.ps1' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
        $CutScript = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\cmds\cut.ps1'))
    }

    BeforeEach {
        $TestDirectory = New-PsCompatTestDirectory
    }

    AfterEach {
        Remove-PsCompatTestDirectory -Path $TestDirectory
    }

    It 'extracts selected fields from a file' {
        $targetPath = Join-Path $TestDirectory 'data.csv'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value @('a,b,c', 'd,e,f')

        $result = Invoke-PsCompatScript -ScriptPath $CutScript -ArgumentList @('-d', ',', '-f', '1,3', $targetPath)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $result.StdOut | Should -Be "a,c`r`nd,f`r`n"
    }

    It 'supports field ranges' {
        $targetPath = Join-Path $TestDirectory 'data.csv'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value @('a,b,c,d')

        $result = Invoke-PsCompatScript -ScriptPath $CutScript -ArgumentList @('-d', ',', '-f', '2-3', $targetPath)

        $result.StdOut | Should -Be "b,c`r`n"
    }

    It 'passes lines without the delimiter through by default' {
        $targetPath = Join-Path $TestDirectory 'data.csv'
        Set-Content -LiteralPath $targetPath -Encoding ASCII -Value @('a,b,c', 'plain')

        $result = Invoke-PsCompatScript -ScriptPath $CutScript -ArgumentList @('-d', ',', '-f', '2', $targetPath)

        $result.StdOut | Should -Be "b`r`nplain`r`n"
    }

    It 'supports pipeline input' {
        $stdin = "a:b:c`nd:e:f`n"

        $result = Invoke-PsCompatScript -ScriptPath $CutScript -ArgumentList @('-d', ':', '-f', '2') -StdIn $stdin

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Be "b`r`ne`r`n"
    }

    It 'returns exit code 2 for invalid usage' {
        $missingFields = Invoke-PsCompatScript -ScriptPath $CutScript -ArgumentList @('-d', ',')
        $badDelimiter = Invoke-PsCompatScript -ScriptPath $CutScript -ArgumentList @('-d', '::', '-f', '1')
        $badFields = Invoke-PsCompatScript -ScriptPath $CutScript -ArgumentList @('-f', 'abc')

        $missingFields.ExitCode | Should -Be 2
        $badDelimiter.ExitCode | Should -Be 2
        $badFields.ExitCode | Should -Be 2
    }

    It 'returns exit code 1 for a missing file' {
        $targetPath = Join-Path $TestDirectory 'missing.csv'

        $result = Invoke-PsCompatScript -ScriptPath $CutScript -ArgumentList @('-d', ',', '-f', '1', $targetPath)

        $result.ExitCode | Should -Be 1
        $result.StdErr | Should -Match 'cut:'
    }
}
