# which

`which.ps1` resolves command names against the current PATH.

## Supported Scope

- resolve the first matching application or external script in `PATH`
- process multiple names in one invocation
- continue after misses and exit non-zero when any lookup fails
- baseline exit codes:
  - `0` for success
  - `1` when any lookup fails
  - `2` for invalid usage

## Usage

```powershell
.\cmds\which.ps1 python
.\cmds\which.ps1 git node
```

Because `which` is not a PowerShell conflict-name command in this repository, bare invocation is acceptable once `cmds\` is on `PATH`.

## Linux Compatibility Notes

- The current MVP prints the first matching PATH-resolved executable or external script for each name.
- Missing names emit `which: no <name> in PATH` and contribute to a non-zero exit code.
- PowerShell aliases and functions are intentionally excluded so the command stays focused on PATH validation.

## Deferred Scope

The following Linux `which` features are intentionally deferred for a later iteration:

- `-a`
- closer parity for shell alias and function resolution semantics
