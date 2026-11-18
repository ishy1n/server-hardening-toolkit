# Architecture

## High-level

```text
┌──────────────────────────────────────────────────────────┐
│                     Developer / Operator                 │
│      sudo ./linux/01-ssh-hardening.sh --dry-run          │
│      .\windows\Disable-SMBv1.ps1 -DryRun                 │
└────────────────────┬─────────────────────────────────────┘
                     │
    ┌────────────────┼──────────────────┐
    │                │                  │
    ▼                ▼                  ▼
┌────────┐      ┌─────────┐      ┌────────────┐
│ Linux  │      │ Windows │      │  Ansible   │
│ bash   │      │ pwsh    │      │ site.yml   │
└───┬────┘      └────┬────┘      └─────┬──────┘
    │                │                 │
    └───────┬────────┴─────────────────┘
            ▼
   ┌───────────────────┐
   │ common.sh /       │
   │ Common.psm1       │
   │ (logging, dry-run,│
   │  mode parsing)    │
   └─────────┬─────────┘
             ▼
   ┌───────────────────┐
   │ /var/log/hardening│
   │ .log (Linux)      │
   │ %ProgramData%\    │
   │ hardening.log     │
   └───────────────────┘
