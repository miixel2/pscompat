# GitHub Copilot Instructions For pscompat

Use these repository files as the instruction hierarchy:

1. `AGENTS.md`
2. `CONVENTIONS.md`
3. `ADDING_COMMANDS.md`
4. `IMPLEMENTATION_ROADMAP.md`

For focused workflow guidance, read `.ai/skills/README.md` and then only the relevant skill file:

- `.ai/skills/pscompat-command-authoring/SKILL.md`
- `.ai/skills/pscompat-pester-parity/SKILL.md`
- `.ai/skills/pscompat-doc-roadmap-sync/SKILL.md`

Repository rules:

- Target Windows PowerShell 5.1 first.
- Implement Linux-like CLI behavior, not generic PowerShell-only behavior.
- Use `Write-Output` for stdout and `Write-Error` or `Write-Warning` for stderr-like output.
- Never use `Write-Host`.
- Avoid external binaries and PowerShell 7-only APIs.
- Keep tests behavior-focused with Pester v5 style.
- Update docs and `IMPLEMENTATION_ROADMAP.md` in the same task whenever practical.

For commands whose names conflict with existing PowerShell aliases, functions, or Windows executables:

- do not rely on bare command invocation
- use explicit script-path invocation in tests and examples
- keep those commands sequenced last, per `IMPLEMENTATION_ROADMAP.md`
