#Requires -Version 5.1

Describe 'tr.ps1' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '_TestHelpers.ps1')
        $TrScript = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\cmds\tr.ps1'))
    }

    It 'translates characters from stdin' {
        $result = Invoke-PsCompatScript -ScriptPath $TrScript -ArgumentList @('abc', 'ABC') -StdIn "abc cab`n"

        $result.ExitCode | Should -Be 0
        $result.StdErr | Should -Be ''
        $result.StdOut | Should -Be "ABC CAB`n"
    }

    It 'supports simple ranges' {
        $result = Invoke-PsCompatScript -ScriptPath $TrScript -ArgumentList @('a-z', 'A-Z') -StdIn "abc xyz`n"

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Be "ABC XYZ`n"
    }

    It 'reuses the last replacement character when set2 is shorter' {
        $result = Invoke-PsCompatScript -ScriptPath $TrScript -ArgumentList @('abc', 'X') -StdIn "abc`n"

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Be "XXX`n"
    }

    It 'deletes selected characters with -d' {
        $result = Invoke-PsCompatScript -ScriptPath $TrScript -ArgumentList @('-d', '0-9') -StdIn "a1b2c3`n"

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Be "abc`n"
    }

    It 'supports common escaped characters' {
        $result = Invoke-PsCompatScript -ScriptPath $TrScript -ArgumentList @('\n', ',') -StdIn "a`nb`n"

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Be "a,b,"
    }

    It 'returns exit code 2 for missing operands' {
        $missingSet1 = Invoke-PsCompatScript -ScriptPath $TrScript
        $missingSet2 = Invoke-PsCompatScript -ScriptPath $TrScript -ArgumentList @('abc')

        $missingSet1.ExitCode | Should -Be 2
        $missingSet2.ExitCode | Should -Be 2
    }
}
