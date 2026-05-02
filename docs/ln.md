# ln (pscompat)

Create hard links and symbolic links using native PowerShell.

## Status

Phase 3 MVP implementation.

## Current Scope

Implemented:

- hard link creation by default: `ln TARGET LINK_NAME`
- symbolic links with `-s`
- force replacement with `-f`
- Linux-style operand errors and non-zero exits

Deferred for later:

- multi-target forms
- backup suffixes and additional GNU flags
- complete parity for all filesystem edge cases

## Examples

```powershell
# hard link
.\cmds\ln.ps1 .\source.txt .\source-link.txt

# symbolic link
.\cmds\ln.ps1 -s .\target.txt .\target-link.txt
```

## Linux Compatibility Notes

- Link creation behavior depends on Windows privileges and filesystem support.
- Directory hard links are not supported by this implementation.
