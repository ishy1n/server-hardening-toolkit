# Contributing

## Commit conventions

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

- `feat(linux): add fail2ban jail` — new feature
- `fix(windows): correct SMB registry path` — bug fix
- `docs: clarify disclaimer` — docs only
- `test: add bats for sysctl` — tests
- `chore: bump actions/checkout to v4` — maintenance

## Before you push

```bash
# Bash syntax
for f in linux/*.sh linux/lib/common.sh; do bash -n "$f"; done

# ShellCheck (optional but recommended)
shellcheck linux/*.sh linux/lib/common.sh

# PowerShell
pwsh -c "Invoke-ScriptAnalyzer ./windows -Recurse"

# Tests
bats tests/bats/
pwsh -c "Invoke-Pester ./tests/pester"
