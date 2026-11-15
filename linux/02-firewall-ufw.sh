#!/usr/bin/env bash
# 02-firewall-ufw.sh — UFW default-deny + allow SSH only
# CIS Ubuntu 24.04 v1.0.0 — Section 3.5
# Usage: sudo ./02-firewall-ufw.sh --dry-run | --apply

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

parse_mode "$@"
require_root
require_cmd ufw

SSH_PORT="${SSH_PORT:-22}"

# ---------- Preflight ----------
log "Mode: ${MODE}"
log "SSH port allowed: ${SSH_PORT}"

# ---------- HARD SAFETY: never enable UFW before allowing SSH ----------
# Otherwise you'll lock yourself out. We do it in the correct order.
do_or_dry ufw --force reset
do_or_dry ufw default deny incoming
do_or_dry ufw default allow outgoing
do_or_dry ufw allow "${SSH_PORT}/tcp" comment 'SSH'
do_or_dry ufw --force enable
do_or_dry ufw logging on

if [[ "$MODE" == "apply" ]]; then
  ufw status verbose | tee -a "$LOG_FILE"
  ok "UFW configured and enabled"
else
  log "[dry-run] No changes applied to UFW."
fi
