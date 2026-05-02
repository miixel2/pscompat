# cut

`cut.ps1` extracts delimiter-separated fields from files or stdin-like pipeline input.

## Supported Scope

- field mode with `-f`
- single-character delimiter selection with `-d`
- comma-separated field lists such as `1,3`
- simple ranges such as `2-4`, `2-`, and `-3`
- file input
- stdin / pipeline input when no file path is supplied
- baseline exit codes:
  - `0` for success
  - `1` for runtime read errors
  - `2` for invalid usage

## Usage

```powershell
.\cmds\cut.ps1 -d , -f 1,3 .\data.csv
.\cmds\cut.ps1 -d : -f 2- .\passwd-like.txt
Get-Content .\data.csv | .\cmds\cut.ps1 -d , -f 2
```

Because `cut` is not a PowerShell conflict-name command in this repository, bare invocation is acceptable once `cmds\` is on `PATH`.

## Linux Compatibility Notes

- Lines that do not contain the delimiter are printed unchanged, matching Linux `cut -f` default behavior.
- Field numbers are one-based.
- Selected fields are printed in the order requested by the field list.

## Deferred Scope

The following Linux `cut` features are intentionally deferred for a later iteration:

- byte mode (`-b`)
- character mode (`-c`)
- `-s`
- `--complement`
- custom output delimiters
