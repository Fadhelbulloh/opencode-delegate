#!/bin/sh
. "$(dirname "$0")/lib.sh"

as() { _s=$1; shift; OPENCODE_SESSION_ID=$_s "$SEND" --feature "$F" "$@" >/dev/null 2>&1; }

test_status_table() {
  as ses_a --to ses_b --type STATUS --status INFO --body i || return 1
  as ses_r --to ses_a --type REVIEW --body r || return 1
  old=$(date -u -r $(( $(date +%s) - 5400 )) +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '-90 minutes' +%Y-%m-%dT%H:%M:%SZ)
  printf '{"ts":"%s","msg":"OLD","feature":"feature","task":"api","from":"ses_a","to":"ses_b","type":"REQUEST","status":"","re":"-","result":"sent","reason":""}\n' "$old" >> "$F/ledger.jsonl"
  out=$("$STATUS" --feature "$F") || return 1
  printf '%s\n' "$out" > "$T/out"
  assert_grep '^| api | 3/24 | 1/1 | 0/1 | OLD ses_a→ses_b 1h |$' "$T/out" || { cat "$T/out"; return 1; }
  assert_grep '^| ui | 0/24 | 0/1 | 0/1 |  |$' "$T/out" || { cat "$T/out"; return 1; }
}

test_status_without_ledger() {
  "$STATUS" --feature "$F" > "$T/out" || return 1
  assert_grep '^| api | 0/24 | 0/1 | 0/1 |  |$' "$T/out"
}

test_status_minutes_age() {
  as ses_a --to ses_b --type REQUEST --body q || return 1
  "$STATUS" --feature "$F" > "$T/out" || return 1
  grep -q 'ses_a→ses_b 0m |$' "$T/out"
}

run_test test_status_table
run_test test_status_without_ledger
run_test test_status_minutes_age
summary
