# Server Hardening Toolkit

[![CI](https://github.com/ishy1n/server-hardening-toolkit/actions/workflows/lint-and-test.yml/badge.svg)](https://github.com/ishy1n/server-hardening-toolkit/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)](https://github.com/ishy1n/server-hardening-toolkit/releases)

**Idempotent, auditable hardening scripts for Linux and Windows servers, mapped to CIS Benchmarks.**

**Идемпотентные скрипты харденинга Linux и Windows с аудитом и привязкой к CIS Benchmarks.**

---

## 🎯 Problem / Проблема

Manual server hardening is error-prone, inconsistent, and hard to audit.
Ручной харденинг серверов подвержен ошибкам, делается непоследовательно и плохо аудируется.

## 💡 Solution / Решение

- **CIS-aligned controls** with dry-run preview
- **Structured logging** of every action
- **Fail-safe** execution
- **Tested in CI**: ShellCheck, PSScriptAnalyzer, Bats, Pester

## 🧰 Stack / Стек

| Layer | Tools |
|---|---|
| Linux hardening | Bash, UFW, fail2ban, auditd, sysctl |
| Windows hardening | PowerShell 7+, Registry / GPO, Defender, Firewall |
| Automation | Ansible (optional) |
| Linting | ShellCheck, PSScriptAnalyzer |
| Testing | Bats-core, Pester |
| CI | GitHub Actions |

## 🚀 Quick Start / Быстрый старт

### Linux

    git clone https://github.com/ishy1n/server-hardening-toolkit.git
    cd server-hardening-toolkit
    sudo ./linux/01-ssh-hardening.sh --dry-run
    sudo ./linux/01-ssh-hardening.sh --apply

### Windows (PowerShell 7+, Run as Administrator)

    git clone https://github.com/ishy1n/server-hardening-toolkit.git
    Set-Location server-hardening-toolkit\windows
    .\Disable-SMBv1.ps1 -DryRun
    .\Disable-SMBv1.ps1 -Apply

## 📋 CIS Benchmark Mapping / Соответствие CIS

Полные таблицы: docs/cis-mapping-linux.md, docs/cis-mapping-windows.md.

### Linux (пример)

| Script | CIS Benchmark | Controls |
|---|---|---|
| 01-ssh-hardening.sh | CIS Ubuntu 24.04 v1.0.0 | 5.1.x |
| 02-firewall-ufw.sh | CIS Ubuntu 24.04 v1.0.0 | 3.5.x |
| 03-fail2ban-setup.sh | CIS Ubuntu 24.04 v1.0.0 | 5.2.x |
| 04-sysctl-hardening.sh | CIS Ubuntu 24.04 v1.0.0 | 1.5.x |
| 05-auditd-setup.sh | CIS Ubuntu 24.04 v1.0.0 | 4.1.x |
| 06-disable-services.sh | CIS Ubuntu 24.04 v1.0.0 | 2.1.x |

### Windows (пример)

| Script | CIS Benchmark | Controls |
|---|---|---|
| Disable-SMBv1.ps1 | CIS WS2022 v5.0.0 | 2.3.1.1 |
| Set-RDPHardening.ps1 | CIS WS2022 v5.0.0 | 2.3.11.x |
| Set-AuditPolicy.ps1 | CIS WS2022 v5.0.0 | 17.x |
| Set-WindowsFirewall.ps1 | CIS WS2022 v5.0.0 | 9.x |
| Set-DefenderBaseline.ps1 | CIS WS2022 v5.0.0 | 18.x |

## 🧪 Testing / Тестирование

    bats tests/bats/
    Invoke-Pester -Path tests/pester/

## 🛡️ Security Disclaimer / Дисклеймер

> **Use only on systems you own or have explicit permission to harden.**
> **Используйте только на своих стендах или там, где есть письменное разрешение.**
> Always run --dry-run first and test in a lab before production.

## 🧠 What I Learned / Skills Demonstrated

- Translating CIS Benchmark controls into idempotent, testable scripts
- Safe-by-default automation (dry-run, fail-fast, structured logging)
- Cross-platform hardening (Bash + PowerShell) with unified logging
- CI for infrastructure code (ShellCheck, PSScriptAnalyzer, Bats, Pester)
- Conventional Commits + PR/Issue templates

## 🗺️ Roadmap

- [x] Project skeleton, README, LICENSE, CI baseline
- [x]Core Linux scripts (SSH, UFW, fail2ban, sysctl, auditd)
- [x] Core Windows scripts (SMBv1, RDP, Firewall, Audit, Defender)
- [x] Ansible role parity
- [x] OpenSCAP / CIS-CAT report generation
- [x] Rollback via state snapshots

## 🤝 Contributing

See CONTRIBUTING.md. Commits follow [Conventional Commits](https://www.conventionalcommits.org/).

## 📄 License

MIT — see LICENSE.
