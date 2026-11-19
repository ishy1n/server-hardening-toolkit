#!/usr/bin/env bats

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  SCRIPT="$REPO_ROOT/linux/01-ssh-hardening.sh"
  LIB="$REPO_ROOT/linux/lib/common.sh"
}

@test "common.sh exists and is syntactically valid" {
  [ -f "$LIB" ]
  bash -n "$LIB"
}

@test "ssh script exists" {
  [ -f "$SCRIPT" ]
}

@test "ssh script is syntactically valid" {
  bash -n "$SCRIPT"
}

@test "ssh script requires --dry-run or --apply" {
  run bash "$SCRIPT"
  [ "$status" -ne 0 ]
}

@test "ssh script --help prints usage and exits 0" {
  run bash "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--dry-run"* ]]
  [[ "$output" == *"--apply"* ]]
}
