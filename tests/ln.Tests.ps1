#Requires -Version 5.1

Describe 'ln.ps1' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
        $LnScript = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\cmds\ln.ps1'))
    }

    BeforeEach {
        $TestDirectory = New-PsCompatTestDirectory
    }

    AfterEach {
        Remove-PsCompatTestDirectory -Path $TestDirectory
    }

    It 'creates a hard link by default' {
        $source = Join-Path $TestDirectory 'source.txt'
        $link = Join-Path $TestDirectory 'link.txt'
        Set-Content -LiteralPath $source -Value 'alpha' -Encoding ASCII

        $result = Invoke-PsCompatScript -ScriptPath $LnScript -ArgumentList @($source, $link)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        (Test-Path -LiteralPath $link) | Should -BeTrue
        (Get-Content -LiteralPath $link -Raw) | Should -Be "alpha`r`n"
    }

    It 'returns exit code 2 when missing operands' {
        $result = Invoke-PsCompatScript -ScriptPath $LnScript -ArgumentList @('only-one')

        $result.ExitCode | Should -Be 2
        $result.StdErr | Should -Match 'missing file operand'
    }

    It 'returns exit code 1 when destination exists without -f' {
        $source = Join-Path $TestDirectory 'source.txt'
        $link = Join-Path $TestDirectory 'link.txt'
        Set-Content -LiteralPath $source -Value 'alpha' -Encoding ASCII
        Set-Content -LiteralPath $link -Value 'beta' -Encoding ASCII

        $result = Invoke-PsCompatScript -ScriptPath $LnScript -ArgumentList @($source, $link)

        $result.ExitCode | Should -Be 1
        $result.StdErr | Should -Match 'File exists'
    }

    It 'supports -f and replaces an existing destination' {
        $source = Join-Path $TestDirectory 'source.txt'
        $link = Join-Path $TestDirectory 'link.txt'
        Set-Content -LiteralPath $source -Value 'alpha' -Encoding ASCII
        Set-Content -LiteralPath $link -Value 'beta' -Encoding ASCII

        $result = Invoke-PsCompatScript -ScriptPath $LnScript -ArgumentList @('-f', $source, $link)

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        (Get-Content -LiteralPath $link -Raw) | Should -Be "alpha`r`n"
    }
}
