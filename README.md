<div align="center">

# 🛡️ Server Hardening Toolkit

**Идемпотентные скрипты харденинга Linux и Windows с аудитом и привязкой к CIS Benchmarks.**

[![CI](https://github.com/ishy1n/server-hardening-toolkit/actions/workflows/lint-and-test.yml/badge.svg)](https://github.com/ishy1n/server-hardening-toolkit/actions/workflows/lint-and-test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![CIS Ubuntu 24.04](https://img.shields.io/badge/CIS-Ubuntu%2024.04%20v1.0.0-blue)](docs/cis-mapping-linux.md)
[![CIS WS2022](https://img.shields.io/badge/CIS-WS2022%20v5.0.0-blue)](docs/cis-mapping-linux.md)

</div>

---

## 🎯 Проблема

Ручной харденинг серверов подвержен ошибкам, делается непоследовательно и плохо аудируется.

## 💡 Решение

- **CIS-aligned controls** — каждый скрипт привязан к конкретным пунктам бенчмарка
- **Dry-run first** — предпросмотр изменений до применения (`--dry-run` / `-DryRun`)
- **Idempotent** — повторный запуск не ломает конфигурацию
- **Fail-safe** — backup + валидация (`sshd -t`) с автоматическим откатом
- **Structured logging** — каждое действие пишется в лог
- **Tested in CI** — ShellCheck, PSScriptAnalyzer, Bats, Pester

## 📁 Структура

```text
server-hardening-toolkit/
├── linux/
│   ├── lib/common.sh            # общие helpers: логирование, parse_mode, set_kv
│   ├── 01-ssh-hardening.sh      # CIS 5.1.x — SSH
│   ├── 02-firewall-ufw.sh       # CIS 3.5.x — UFW default-deny
│   ├── 03-fail2ban-setup.sh     # CIS 5.2.x — anti-bruteforce
│   └── 04-sysctl-hardening.sh   # CIS 1.5.x — kernel/network
├── windows/
│   ├── lib/Common.psm1          # Write-HardeningLog, Assert-Administrator
│   ├── Disable-SMBv1.ps1        # CIS 2.3.1.1 — SMBv1 off + signing/encryption
│   └── Set-RDPHardening.ps1     # CIS 2.3.11.x — NLA, encryption, timeouts
├── ansible/                     # опциональная Ansible-обёртка (паритет со скриптами)
├── tests/
│   ├── bats/                    # smoke-тесты Bash-скриптов
│   └── pester/                  # smoke-тесты PowerShell-скриптов
├── docs/
│   ├── architecture.md          # общая архитектура
│   └── cis-mapping-linux.md     # полная таблица соответствия CIS
├── .github/workflows/           # CI: lint + test на каждый push/PR
└── README.md
```

## ⚙️ Требования

| Платформа | Минимум |
|---|---|
| Linux | Ubuntu 22.04/24.04 (bash 4+, root), пакеты: `openssh-server`, `ufw`, `fail2ban` |
| Windows | Windows Server 2016+ / Windows 10+, PowerShell 7+, запуск от Administrator |

## 🚀 Быстрый старт

> ⚠️ Всегда начинайте с dry-run и тестируйте на стенде до production.

### Linux

```bash
git clone https://github.com/ishy1n/server-hardening-toolkit.git
cd server-hardening-toolkit

# 1. Предпросмотр
sudo ./linux/01-ssh-hardening.sh --dry-run

# 2. Применение (автоматически делает backup и валидирует sshd -t)
sudo ./linux/01-ssh-hardening.sh --apply

# Остальные скрипты — в любом порядке
sudo ./linux/02-firewall-ufw.sh --apply      # SSH_PORT=2222 для нестандартного порта
sudo ./linux/03-fail2ban-setup.sh --apply    # BAN_TIME=1h FIND_TIME=10m MAX_RETRY=5
sudo ./linux/04-sysctl-hardening.sh --apply
```

### Windows (PowerShell 7+, Run as Administrator)

```powershell
git clone https://github.com/ishy1n/server-hardening-toolkit.git
Set-Location server-hardening-toolkit\windows

.\Disable-SMBv1.ps1 -DryRun     # предпросмотр
.\Disable-SMBv1.ps1 -Apply      # применение (SMB1Protocol feature → reboot может быть нужен)

.\Set-RDPHardening.ps1 -Apply
```

Логи: `/var/log/hardening.log` (Linux), `%ProgramData%\hardening.log` (Windows).

## 📋 Соответствие CIS

Полная таблица: [docs/cis-mapping-linux.md](docs/cis-mapping-linux.md).

### Linux (CIS Ubuntu 24.04 v1.0.0)

| Script | Controls | Что делает |
|---|---|---|
| `01-ssh-hardening.sh` | 5.1.x | root login off, ключи вместо паролей, MaxAuthTries=4, X11 off, verbose logging |
| `02-firewall-ufw.sh` | 3.5.1.x | UFW default-deny incoming, allow SSH, logging on |
| `03-fail2ban-setup.sh` | 5.2.x | jail.local: bantime=1h, maxretry=5, sshd jail |
| `04-sysctl-hardening.sh` | 1.5.x | ip_forward off, redirects off, rp_filter, SYN cookies, martians logging |

### Windows (CIS WS2022 v5.0.0)

| Script | Controls | Что делает |
|---|---|---|
| `Disable-SMBv1.ps1` | 2.3.1.1 | SMB1=0 (server+workstation), required signing, encrypted data, optional feature off |
| `Set-RDPHardening.ps1` | 2.3.11.x | NLA required, High encryption, drive/printer redirection off, idle timeout 15 мин |

## 🧪 Тестирование

```bash
# Bash
bats tests/bats/

# PowerShell
Invoke-Pester -Path tests/pester/ -Output Detailed
```

CI на каждый push/PR: ShellCheck → PSScriptAnalyzer → Bats → Pester ([workflow](.github/workflows/lint-and-test.yml)).

## 🧰 Ansible (optional)

```bash
ansible-playbook -i inventory.ini ansible/site.yml
```

Роль `hardening` дублирует логику скриптов для fleet-управления; defaults в `ansible/roles/hardening/defaults/main.yml` (порт SSH, MaxAuthTries, fail2ban-пороги — переопределяются через `group_vars`/`-e`).

## 🛡️ SДисклеймер

> **Используйте только на своих стендах или там, где есть письменное разрешение.**
> Скрипты меняют SSH/firewall — ошибка может отрезать вам доступ. Dry-run → стенд → backup → production.


## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Commits follow [Conventional Commits](https://www.conventionalcommits.org/). PR checklist: dry-run support, логирование, валидация, зелёный CI, обновлённый README/CIS-mapping.

## 📄 License

[MIT](LICENSE) — используйте на свой страх и риск.
