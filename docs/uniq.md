# uniq

`uniq.ps1` filters adjacent duplicate lines from files or stdin-like pipeline input.

## Supported Scope

- default adjacent duplicate collapse
- `-c` for counts
- `-d` for repeated runs only
- `-u` for unique runs only
- `-i` for case-insensitive comparison
- one input file or stdin / pipeline input
- baseline exit codes:
  - `0` for success
  - `1` for runtime read errors
  - `2` for invalid or unsupported usage

## Usage

```powershell
.\cmds\uniq.ps1 .\sorted.txt
.\cmds\uniq.ps1 -c .\sorted.txt
.\cmds\uniq.ps1 -d .\sorted.txt
Get-Content .\sorted.txt | .\cmds\uniq.ps1 -i
```

Because `uniq` is not a PowerShell conflict-name command in this repository, bare invocation is acceptable once `cmds\` is on `PATH`.

## Linux Compatibility Notes

- `uniq` only compares adjacent lines. It does not sort input.
- Count formatting uses the Linux-style right-aligned count prefix.
- With `-i`, the first line in an adjacent case-insensitive run is preserved.

## Deferred Scope

The following Linux `uniq` features are intentionally deferred for a later iteration:

- skip field / skip character options
- repeated group printing variants
- output-file operand support
