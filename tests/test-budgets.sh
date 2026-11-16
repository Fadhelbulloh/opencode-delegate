#!/bin/sh
. "$(dirname "$0")/lib.sh"

as() { _s=$1; shift; OPENCODE_SESSION_ID=$_s "$SEND" --feature "$F" "$@" >/dev/null 2>&1; }
refused() {
  _want=$1; shift
  as "$@"; _rc=$?
  [ "$_rc" = 2 ] || { echo "  exit $_rc, want 2"; return 1; }
  _r=$(ledger_last "$F" | jq -r .reason)
  [ "$_r" = "$_want" ] || { echo "  reason [$_r] want [$_want]"; return 1; }
}
set_budget() { jq -c "$1" "$F/budgets.json" > "$F/b.tmp" && mv "$F/b.tmp" "$F/budgets.json"; }
info() { as "$1" --to "$2" --type STATUS --status INFO --body i; }

test_message_over_budget_refused() {
  set_budget '.api.messages = 3'
  info ses_a ses_b && info ses_a ses_b && info ses_a ses_b || return 1
  refused "task budget exhausted (3/3)" ses_a --to ses_b --type STATUS --status INFO --body i
}

test_main_messages_count_toward_task() {
  set_budget '.api.messages = 2'
  as ses_main --task api --to ses_a --type STATUS --status INFO --body i || return 1
  info ses_a ses_b || return 1
  refused "task budget exhausted (2/2)" ses_a --to ses_b --type STATUS --status INFO --body i
}

test_refused_lines_do_not_count() {
  set_budget '.api.messages = 3'
  as ses_a --to ses_a --type STATUS --status INFO --body i
  info ses_a ses_b && info ses_a ses_b && info ses_a ses_b
}

test_second_review_refused() {
  as ses_r --to ses_a --type REVIEW --body r || return 1
  refused "review budget exhausted" ses_r --to ses_a --type REVIEW --body r
}

test_second_verify_refused() {
  as ses_r --to ses_a --type REVIEW_VERIFY --body v || return 1
  refused "verify budget exhausted" ses_r --to ses_a --type REVIEW_VERIFY --body v
}

test_budget_raise_takes_effect() {
  as ses_r --to ses_a --type REVIEW --body r || return 1
  refused "review budget exhausted" ses_r --to ses_a --type REVIEW --body r || return 1
  set_budget '.api.review = 2'
  as ses_r --to ses_a --type REVIEW --body r
}

test_missing_task_budget_refused() {
  echo '{}' > "$F/budgets.json"
  refused "no budget for task api" ses_a --to ses_b --type STATUS --status INFO --body i
}

test_unreadable_budgets_refused() {
  rm "$F/budgets.json"
  refused "budgets.json unreadable" ses_a --to ses_b --type STATUS --status INFO --body i
}

run_test test_message_over_budget_refused
run_test test_main_messages_count_toward_task
run_test test_refused_lines_do_not_count
run_test test_second_review_refused
run_test test_second_verify_refused
run_test test_budget_raise_takes_effect
run_test test_missing_task_budget_refused
run_test test_unreadable_budgets_refused
summary
