#!/usr/bin/env bash
# 01-ssh-hardening.sh — CIS-aligned SSH hardening
# CIS Ubuntu 24.04 v1.0.0 — Section 5.1
# Usage: sudo ./01-ssh-hardening.sh --dry-run | --apply

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

parse_mode "$@"
require_root
require_cmd sshd
require_cmd grep

SSHD_CONFIG="/etc/ssh/sshd_config"

# ---------- Preflight ----------
[[ -f "$SSHD_CONFIG" ]] || die "Not found: $SSHD_CONFIG"
ok "Config: $SSHD_CONFIG"
log "Mode: ${MODE}"

# ---------- Backup ----------
BACKUP="${SSHD_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
if [[ "$MODE" == "apply" ]]; then
  cp -a "$SSHD_CONFIG" "$BACKUP"
  ok "Backup: $BACKUP"
fi

# ---------- CIS 5.1 controls ----------
set_kv "$SSHD_CONFIG" "PermitRootLogin"        "no"
set_kv "$SSHD_CONFIG" "PasswordAuthentication" "no"
set_kv "$SSHD_CONFIG" "PermitEmptyPasswords"   "no"
set_kv "$SSHD_CONFIG" "PubkeyAuthentication"   "yes"
set_kv "$SSHD_CONFIG" "MaxAuthTries"           "4"
set_kv "$SSHD_CONFIG" "MaxSessions"            "4"
set_kv "$SSHD_CONFIG" "LoginGraceTime"         "60"
set_kv "$SSHD_CONFIG" "X11Forwarding"          "no"
set_kv "$SSHD_CONFIG" "AllowAgentForwarding"   "no"
set_kv "$SSHD_CONFIG" "ClientAliveInterval"    "300"
set_kv "$SSHD_CONFIG" "ClientAliveCountMax"    "3"
set_kv "$SSHD_CONFIG" "LogLevel"               "VERBOSE"
set_kv "$SSHD_CONFIG" "Banner"                 "/etc/issue.net"

# ---------- Validate & reload ----------
if [[ "$MODE" == "apply" ]]; then
  if ! sshd -t; then
    warn "sshd -t FAILED. Restoring from $BACKUP"
    cp -a "$BACKUP" "$SSHD_CONFIG"
    die "Aborted: config rolled back."
  fi
  ok "sshd -t: config valid"
  systemctl reload sshd 2>/dev/null || systemctl reload ssh 2>/dev/null || die "Failed to reload sshd"
  ok "sshd reloaded"
else
  log "[dry-run] No changes written. Re-run with --apply."
fi
