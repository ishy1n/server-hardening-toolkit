# CIS Benchmark Mapping — Linux

Reference: **CIS Ubuntu 24.04 LTS Benchmark v1.0.0**

| Script | CIS control | Description | Status |
|---|---|---|---|
| 01-ssh-hardening.sh | 5.1.1 | Ensure permissions on /etc/ssh/sshd_config | Manual |
| 01-ssh-hardening.sh | 5.1.4 | Disable X11Forwarding | ✅ |
| 01-ssh-hardening.sh | 5.1.7 | Set MaxAuthTries | ✅ |
| 01-ssh-hardening.sh | 5.1.8 | Disable root login | ✅ |
| 01-ssh-hardening.sh | 5.1.10 | Disable password authentication | ✅ |
| 01-ssh-hardening.sh | 5.1.14 | Disable empty passwords | ✅ |
| 02-firewall-ufw.sh | 3.5.1.1 | Ensure UFW is installed | ✅ |
| 02-firewall-ufw.sh | 3.5.1.2 | Ensure UFW service is enabled | ✅ |
| 02-firewall-ufw.sh | 3.5.1.3 | Default deny incoming | ✅ |
| 02-firewall-ufw.sh | 3.5.1.4 | Default allow outgoing | ✅ |
| 03-fail2ban-setup.sh | 5.2.1 | Ensure fail2ban is installed | ✅ |
| 03-fail2ban-setup.sh | 5.2.2 | Ensure fail2ban is enabled | ✅ |
| 04-sysctl-hardening.sh | 1.5.1 | Disable IP forwarding | ✅ |
| 04-sysctl-hardening.sh | 1.5.2 | Disable packet redirects | ✅ |
| 04-sysctl-hardening.sh | 1.5.3 | Disable source routed packets | ✅ |
| 04-sysctl-hardening.sh | 1.5.4 | Disable ICMP redirects | ✅ |
| 04-sysctl-hardening.sh | 1.5.8 | Enable reverse path filtering | ✅ |
| 04-sysctl-hardening.sh | 1.5.9 | Enable SYN cookies | ✅ |
| 04-sysctl-hardening.sh | 1.5.10 | Disable IPv6 RA | ✅ |
