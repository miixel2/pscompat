# Adding a New Command

## Checklist

1. Create `cmds/<command>.ps1` using the template below
2. Create `tests/<command>.Tests.ps1` with Pester v5
3. Add usage notes to `docs/<command>.md`
4. Update `README.md` command table

## Script Template

```powershell
#Requires -Version 5.1
<#
.SYNOPSIS
    Emulates Linux `<command>` command.

.DESCRIPTION
    Behavioral differences from Linux:
    - <difference 1>
    - <difference 2>

.PARAMETER Path
    <description>

.EXAMPLE
    # Linux:
    <command> <args>

    # pscompat:
    .\<command>.ps1 <args>
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(ValueFromPipeline)]
    [string]$Input
)

begin {
    $ErrorActionPreference = 'Stop'
}

process {
    try {
        # implementation
    } catch {
        Write-Error "<command>: $($_.Exception.Message)"
        exit 1
    }
}
```

## Test Template

```powershell
#Requires -Version 5.1
BeforeAll {
    . "$PSScriptRoot/../cmds/<command>.ps1"
}

Describe '<command>' {
    Context 'Happy path' {
        It 'should <expected behavior>' {
            # arrange / act / assert
        }
    }

    Context 'Bad input' {
        It 'should exit 1 on missing file' {
            # assert exit code
        }
    }

    Context 'Pipeline input' {
        It 'should accept stdin' {
            # pipe test
        }
    }
}
```
