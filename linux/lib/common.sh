#!/usr/bin/env bash
# linux/lib/common.sh — shared helpers for all Linux hardening scripts
# Sourced by hardening scripts. Do not execute directly.

set -u

LOG_FILE="${HARDENING_LOG:-/var/log/hardening.log}"
MODE=""          # "dry-run" | "apply"
SCRIPT_NAME="$(basename "${0:-unknown}")"

# Colors (skip if not a tty)
if [[ -t 1 ]]; then
  C_RED=$'\033[1;31m'; C_GRN=$'\033[1;32m'; C_YEL=$'\033[1;33m'; C_BLU=$'\033[1;34m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YEL=""; C_BLU=""; C_RST=""
fi

_ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

_log_file() {
  # try to append to log; fallback to stderr if no permission
  local line="$1"
  if [[ -w "$LOG_FILE" ]] || touch "$LOG_FILE" 2>/dev/null; then
    printf '%s\n' "$line" >> "$LOG_FILE"
  else
    printf '%s\n' "$line" >&2
  fi
}

log()  { local m="[$( _ts )] [${MODE:-info}] [${SCRIPT_NAME}] $*"; printf '%s%s%s\n' "$C_BLU" "$m" "$C_RST"; _log_file "$m"; }
ok()   { local m="[$( _ts )] [OK] [${SCRIPT_NAME}] $*";     printf '%s%s%s\n' "$C_GRN" "$m" "$C_RST"; _log_file "$m"; }
warn() { local m="[$( _ts )] [WARN] [${SCRIPT_NAME}] $*";   printf '%s%s%s\n' "$C_YEL" "$m" "$C_RST"; _log_file "$m"; }
die()  { local m="[$( _ts )] [FATAL] [${SCRIPT_NAME}] $*";  printf '%s%s%s\n' "$C_RED" "$m" "$C_RST"; _log_file "$m"; exit 1; }

require_root() {
  [[ ${EUID} -eq 0 ]] || die "Run as root (sudo)."
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing command: $1"
}

parse_mode() {
  # Accepts --dry-run / --apply, sets MODE. Usage: parse_mode "$@"
  local arg
  for arg in "$@"; do
    case "$arg" in
      --dry-run) MODE="dry-run" ;;
      --apply)   MODE="apply"   ;;
      -h|--help)
        cat <<EOF
Usage: $SCRIPT_NAME [--dry-run|--apply]
  --dry-run   Preview changes (default if nothing given)
  --apply     Actually apply changes
EOF
        exit 0
        ;;
      *) die "Unknown argument: $arg (use --dry-run or --apply)" ;;
    esac
  done
  [[ -z "$MODE" ]] && die "Specify --dry-run or --apply. See --help."
}

# Wrapper: run a mutating command only in apply mode
do_or_dry() {
  if [[ "$MODE" == "apply" ]]; then
    "$@"
  else
    log "[dry-run] would run: $*"
  fi
}

# Idempotent key=value setter for sshd_config-style files
# Usage: set_kv /path/to/file Key "value" [--sep=space|equals]
set_kv() {
  local file="$1" key="$2" value="$3" sep="space"
  [[ "${4:-}" == "--sep=equals" ]] && sep="equals"
  [[ -f "$file" ]] || die "File not found: $file"

  local line
  if [[ "$sep" == "equals" ]]; then
    line="${key}=${value}"
  else
    line="${key} ${value}"
  fi

  if grep -qE "^[[:space:]]*#?[[:space:]]*${key}([[:space:]=]|$)" "$file"; then
    if [[ "$MODE" == "apply" ]]; then
      # replace the first active/comment occurrence, escape sed special chars in value
      local esc_value
      esc_value=$(printf '%s' "$value" | sed -e 's/[\/&|]/\\&/g')
      sed -i -E "0,/^[[:space:]]*#?[[:space:]]*${key}([[:space:]=].*)?$/s//${line}/" "$file"
    fi
    log "update ${key} -> ${value}  (${file})"
  else
    [[ "$MODE" == "apply" ]] && printf '%s\n' "$line" >> "$file"
    log "append ${key} -> ${value}  (${file})"
  fi
}
