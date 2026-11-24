# 🛡️ Server Hardening Toolkit

**Идемпотентные скрипты харденинга Linux и Windows с аудитом и привязкой к CIS Benchmarks.**

[![DevSecOps Pipeline](https://github.com/ishy1n/server-hardening-toolkit/actions/workflows/security-scan.yml/badge.svg)](https://github.com/ishy1n/server-hardening-toolkit/actions/workflows/security-scan.yml)
[![Container Security](https://github.com/ishy1n/server-hardening-toolkit/actions/workflows/container-security.yml/badge.svg)](https://github.com/ishy1n/server-hardening-toolkit/actions/workflows/container-security.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🎯 Проблема

Ручной харденинг серверов подвержен ошибкам, делается непоследовательно и плохо аудируется. Кроме того, сами скрипты автоматизации являются критическим активом: уязвимость в них может привести к компрометации всей инфраструктуры.

## 💡 Решение

Проект решает проблему с двух сторон:
1.  **Надежный харденинг:** Скрипты для Linux и Windows, строго следующие CIS Benchmarks.
2.  **Безопасность самого инструмента (Supply Chain Security):** Внедрен сквозной DevSecOps-пайплайн, который гарантирует, что в код не попадут секреты, уязвимости или небезопасные конфигурации.

### Ключевые особенности:
*   **CIS-aligned controls** — каждый скрипт привязан к конкретным пунктам бенчмарка.
*   **Dry-run first** — предпросмотр изменений до применения (`--dry-run` / `-DryRun`).
*   **Idempotent** — повторный запуск не ломает конфигурацию.
*   **Fail-safe** — backup + валидация (`sshd -t`) с автоматическим откатом.
*   **Structured logging** — каждое действие пишется в лог.
*   **Tested in CI** — ShellCheck, PSScriptAnalyzer, Bats, Pester.
*   **🛡️ DevSecOps Pipeline** — автоматический SAST, поиск секретов и сканирование контейнеров.

---

## 🏗 Архитектура безопасности (DevSecOps Pipeline)

Безопасность проекта не заканчивается на написании bash-скриптов. При каждом коммите в репозиторий запускается пайплайн GitHub Actions, реализующий принцип **"Shift-Left Security"**:

1.  **Secrets Detection (Gitleaks):** Сканирование всей истории Git на наличие захардкоженных паролей и ключей.
2.  **SAST (Semgrep):** Статический анализ Bash и Python кода на наличие уязвимостей и небезопасных паттернов.
3.  **Container Security (Trivy):** Сборка Docker-образа, проверка пакетов на CVE и выявление мисконфигураций (например, запуск от `root`).
4.  **Branch Protection:** Настроены «предохранители» (Security Gates) — слияние Pull Request физически блокируется, если проверки не пройдены.

### ⚠️ Важно: Предварительная настройка для работы пайплайна

Если вы форкнули или клонировали этот репозиторий, убедитесь, что у вас включены нужные настройки, иначе проверки не будут запускаться:

1.  **Включите GitHub Actions:** Перейдите в `Settings` -> `Actions` -> `General` -> выберите **Allow all actions and reusable workflows**.
2.  **Включите сканирование секретов:** Перейдите в `Settings` -> `Code security and analysis` -> включите **Secret scanning** и **Dependabot alerts**.
3.  **Настройте Branch Protection (Защита веток):** Перейдите в `Settings` -> `Branches` -> `Add branch protection rule` для ветки `main`. Включите галочки:
    *   **Require a pull request before merging**
    *   **Require status checks to pass before merging** (выберите `SAST (Semgrep)`, `Secrets Detection (Gitleaks)` и `Build & Scan Image`).
    *   *Без этого кнопка Merge будет активна даже при упавших проверках!*

### 📸 Доказательства работы защиты (Security Gates in Action)

**1. Блокировка слияния уязвимого кода (Merge Blocked)**
При попытке внедрить тестовый секрет и сломать Dockerfile, пайплайн падает с ошибкой, а кнопка "Merge pull request" становится неактивной.

<!-- ИНСТРУКЦИЯ: Как прикрепить картинку -->
<!-- 1. Создайте в репозитории папку assets (например: git mkdir assets) -->
<!-- 2. Закиньте туда скриншоты -->
<!-- 3. Используйте синтаксис: ![Название](путь_к_картинке) -->

![Блокировка слияния PR](assets/merge-blocked.png)
> *На скриншоте: Система Branch Protection блокирует слияние PR из-за проваленных проверок SAST и Trivy.*

**2. Отчеты сканеров во вкладке Security**
Результаты сканирования (SARIF) интегрированы в GitHub Security Tab, что позволяет быстро анализировать проблемы.

![Отчеты Trivy в Security](assets/trivy-report.png)
> *На скриншоте: Trivy обнаружил мисконфигурацию DS002 (Image user should not be root) в Dockerfile.*

---

## 📁 Структура

    server-hardening-toolkit/
    ├── .github/workflows/           # CI: lint + test + DevSecOps (SAST, Gitleaks, Trivy)
    ├── assets/                      # Скриншоты и изображения для документации
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
    ├── Dockerfile                   # Контейнер для безопасного запуска и сканирования
    └── README.md

## ⚙️ Требования

Платформа | Минимум  
---|---  
Linux | Ubuntu 22.04/24.04 (bash 4+, root), пакеты: `openssh-server`, `ufw`, `fail2ban`  
Windows | Windows Server 2016+ / Windows 10+, PowerShell 7+, запуск от Administrator  

## 🚀 Быстрый старт

> ⚠️ Всегда начинайте с dry-run и тестируйте на стенде до production.

### Linux

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

### Windows (PowerShell 7+, Run as Administrator)

    git clone https://github.com/ishy1n/server-hardening-toolkit.git
    Set-Location server-hardening-toolkit\windows

    .\Disable-SMBv1.ps1 -DryRun     # предпросмотр
    .\Disable-SMBv1.ps1 -Apply      # применение (SMB1Protocol feature → reboot может быть нужен)

    .\Set-RDPHardening.ps1 -Apply

Логи: `/var/log/hardening.log` (Linux), `%ProgramData%\hardening.log` (Windows).

## 📋 Соответствие CIS

Полная таблица: docs/cis-mapping-linux.md.

### Linux (CIS Ubuntu 24.04 v1.0.0)

Script | Controls | Что делает  
---|---|---  
`01-ssh-hardening.sh` | 5.1.x | root login off, ключи вместо паролей, MaxAuthTries=4, X11 off, verbose logging  
`02-firewall-ufw.sh` | 3.5.1.x | UFW default-deny incoming, allow SSH, logging on  
`03-fail2ban-setup.sh` | 5.2.x | jail.local: bantime=1h, maxretry=5, sshd jail  
`04-sysctl-hardening.sh` | 1.5.x | ip_forward off, redirects off, rp_filter, SYN cookies, martians logging  

### Windows (CIS WS2022 v5.0.0)

Script | Controls | Что делает  
---|---|---  
`Disable-SMBv1.ps1` | 2.3.1.1 | SMB1=0 (server+workstation), required signing, encrypted data, optional feature off  
`Set-RDPHardening.ps1` | 2.3.11.x | NLA required, High encryption, drive/printer redirection off, idle timeout 15 мин  

## 🧪 Тестирование

    # Bash
    bats tests/bats/

    # PowerShell
    Invoke-Pester -Path tests/pester/ -Output Detailed

CI на каждый push/PR: ShellCheck → PSScriptAnalyzer → Bats → Pester → **DevSecOps Pipeline (Gitleaks, Semgrep, Trivy)**.

## 🧰 Ansible (optional)

    ansible-playbook -i inventory.ini ansible/site.yml

Роль `hardening` дублирует логику скриптов для fleet-управления; defaults в `ansible/roles/hardening/defaults/main.yml` (порт SSH, MaxAuthTries, fail2ban-пороги — переопределяются через `group_vars`/`-e`).

## 🛡️ Дисклеймер

> **Используйте только на своих стендах или там, где есть письменное разрешение.** Скрипты меняют SSH/firewall — ошибка может отрезать вам доступ. Dry-run → стенд → backup → production.

## 🤝 Contributing

See CONTRIBUTING.md. Commits follow Conventional Commits. PR checklist: dry-run support, логирование, валидация, зелёный CI, обновлённый README/CIS-mapping.

## 📄 License

MIT — используйте на свой страх и риск.
