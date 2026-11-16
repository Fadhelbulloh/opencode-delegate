#!/bin/sh
. "$(dirname "$0")/lib.sh"

test_sends_request_with_queue_delivery() {
  assert_exit 0 "$SEND" --feature "$F" --to ses_b --type REQUEST --body "hello" || return 1
  assert_grep '^api session.prompt --param sessionID=ses_b --data ' "$T/calls.log" || return 1
  d=$(last_data "$T")
  [ "$(printf '%s' "$d" | jq -r .delivery)" = queue ] || { echo "  delivery not queue"; return 1; }
  printf '%s' "$d" | jq -r .text | head -n 1 | grep -q '^\[tw msg=m[0-9]*-[0-9a-f]* feature=feature task=api from=ses_a to=ses_b type=REQUEST re=-\]$' || { echo "  bad header: $(printf '%s' "$d" | jq -r .text | head -n 1)"; return 1; }
}

test_ledger_line_written() {
  "$SEND" --feature "$F" --to ses_b --type REQUEST --body "hello" >/dev/null || return 1
  l=$(ledger_last "$F")
  [ "$(printf '%s' "$l" | jq -r '.result,.task,.type,.from,.to' | tr '\n' ' ')" = "sent api REQUEST ses_a ses_b " ] || { echo "  ledger: $l"; return 1; }
}

test_first_message_without_ledger_file() {
  rm -f "$F/ledger.jsonl"
  assert_exit 0 "$SEND" --feature "$F" --to ses_b --type REQUEST --body "x"
}

test_body_with_quotes_and_newlines() {
  body=$(printf 'say "hi" \\ back\n]done')
  "$SEND" --feature "$F" --to ses_b --type REQUEST --body "$body" >/dev/null || return 1
  got=$(last_data "$T" | jq -r .text | tail -n +2)
  [ "$got" = "$body" ] || { printf '  body mismatch:\n%s\n' "$got"; return 1; }
}

test_body_from_stdin() {
  printf 'from stdin' | "$SEND" --feature "$F" --to ses_b --type REQUEST --body - >/dev/null || return 1
  [ "$(last_data "$T" | jq -r .text | tail -n +2)" = "from stdin" ]
}

test_status_header_includes_substatus() {
  "$SEND" --feature "$F" --to ses_b --type STATUS --status BLOCKED --body "need x" >/dev/null || return 1
  last_data "$T" | jq -r .text | head -n 1 | grep -q 'type=STATUS/BLOCKED re=-\]$'
}

test_usage_error_without_type() {
  assert_exit 1 "$SEND" --feature "$F" --to ses_b --body "x" || return 1
  [ ! -f "$T/calls.log" ]
}

test_usage_error_status_without_status() {
  assert_exit 1 "$SEND" --feature "$F" --to ses_b --type STATUS --body "x"
}

run_test test_sends_request_with_queue_delivery
run_test test_ledger_line_written
run_test test_first_message_without_ledger_file
run_test test_body_with_quotes_and_newlines
run_test test_body_from_stdin
run_test test_status_header_includes_substatus
run_test test_usage_error_without_type
run_test test_usage_error_status_without_status
summary
