# Adding a New Command

This file is the repository-root source of truth for the new-command workflow.
The copy under `docs/` exists for reader convenience and should stay aligned with this file.

## Checklist

1. Create `cmds/<command>.ps1` using the project script template
2. Create `tests/<command>.Tests.ps1` with Pester v5
3. Add usage notes to `docs/<command>.md`
4. Update `README.md`
5. Update `IMPLEMENTATION_ROADMAP.md`

## Script Template

```powershell
#Requires -Version 5.1
<#
.SYNOPSIS
    Emulates Linux `<command>`.

.DESCRIPTION
    Behavioral differences from Linux:
    - <difference 1>
    - <difference 2>

.EXAMPLE
    # Linux:
    <command> <args>

    # pscompat:
    .\cmds\<command>.ps1 <args>
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(ValueFromPipeline)]
    [string]$InputObject
)

begin {
    $ErrorActionPreference = 'Stop'
}

process {
    try {
        # implementation
    }
    catch {
        Write-Error "<command>: $($_.Exception.Message)"
        exit 1
    }
}
```

## Test Template

```powershell
#Requires -Version 5.1

BeforeAll {
    . "$PSScriptRoot\_TestHelpers.ps1"
}

Describe '<command>' {
    It 'matches the expected happy path output' {
        # arrange / act / assert
    }

    It 'returns exit code 2 for invalid usage' {
        # arrange / act / assert
    }

    It 'handles explicit script-path invocation' {
        # arrange / act / assert
    }
}
```

## Conflict Command Rule

For commands that collide with PowerShell aliases, functions, or Windows executables:

- invoke them by explicit script path in tests and docs
- do not assume adding `cmds/` to `PATH` makes the bare command name resolve to `pscompat`
