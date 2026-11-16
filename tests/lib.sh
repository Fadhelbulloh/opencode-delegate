#!/bin/sh
# Shared helpers for tests/test-*.sh. Source it; do not run it.

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SEND="$ROOT/bin/teamwork-send"
STATUS="$ROOT/bin/teamwork-status"
PASS=0
FAIL=0

# fixture <dir>: feature dir with members.json + budgets.json, no ledger.
fixture() {
  mkdir -p "$1/briefs" "$1/reports"
  cat > "$1/members.json" <<'EOF'
{ "main": "ses_main",
  "members": { "ses_a": { "task": "api", "peers": ["ses_main", "ses_b"] },
               "ses_b": { "task": "ui",  "peers": ["ses_main", "ses_a"] },
               "ses_r": { "task": "api", "peers": ["ses_main", "ses_a"], "role": "reviewer" } } }
EOF
  cat > "$1/budgets.json" <<'EOF'
{ "api": { "messages": 24, "review": 1, "verify": 1 }, "ui": { "messages": 24, "review": 1, "verify": 1 } }
EOF
}

# fake_opencode <dir>: shim `opencode` on PATH that logs args to <dir>/calls.log.
fake_opencode() {
  mkdir -p "$1/bin"
  cat > "$1/bin/opencode" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >> "$1/calls.log"
EOF
  chmod +x "$1/bin/opencode"
  PATH="$1/bin:$PATH"
  export PATH
}

# last_data <dir>: the JSON after --data of the last fake call.
last_data() {
  tail -n 1 "$1/calls.log" | sed 's/.*--data //'
}

ledger_last() { tail -n 1 "$1/ledger.jsonl"; }

# assert_exit <code> <cmd...>
assert_exit() {
  _want=$1; shift
  "$@" >/dev/null 2>&1
  _got=$?
  [ "$_got" = "$_want" ] && return 0
  printf '  exit: want %s got %s: %s\n' "$_want" "$_got" "$*"
  return 1
}

# assert_grep <pattern> <file>
assert_grep() {
  grep -q -- "$1" "$2" && return 0
  printf '  missing %s in %s\n' "$1" "$2"
  return 1
}

# run_test <name>: runs function <name> in a fresh tmp dir; counts result.
run_test() {
  T=$(mktemp -d)
  F="$T/feature"
  fixture "$F"
  fake_opencode "$T"
  OPENCODE_SESSION_ID=ses_a
  export OPENCODE_SESSION_ID
  if ( cd "$T" && "$1" ); then
    PASS=$((PASS + 1)); printf 'ok   %s\n' "$1"
  else
    FAIL=$((FAIL + 1)); printf 'FAIL %s\n' "$1"
  fi
  rm -rf "$T"
}

summary() {
  printf '%s passed, %s failed\n' "$PASS" "$FAIL"
  [ "$FAIL" = 0 ]
}
