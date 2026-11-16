#!/bin/sh
. "$(dirname "$0")/lib.sh"

refused_with() { # refused_with <reason> <args...>
  want=$1; shift
  assert_exit 2 "$SEND" "$@" || return 1
  [ "$(ledger_last "$F" | jq -r '.result + ":" + .reason')" = "refused:$want" ] || { echo "  ledger: $(ledger_last "$F")"; return 1; }
  [ ! -f "$T/calls.log" ] || { echo "  message was sent"; return 1; }
}

test_unknown_sender_refused() {
  OPENCODE_SESSION_ID=ses_zz refused_with "not a member" --feature "$F" --to ses_b --type REQUEST --body x
}

test_main_is_member() {
  OPENCODE_SESSION_ID=ses_main assert_exit 0 "$SEND" --feature "$F" --task api --to ses_a --type REQUEST --body x
}

test_non_peer_refused() {
  refused_with "recipient not in peers" --feature "$F" --to ses_r --type REQUEST --body x
}

test_self_send_refused() {
  refused_with "self-send" --feature "$F" --to ses_a --type REQUEST --body x
}

test_missing_members_refused() {
  rm "$F/members.json"
  refused_with "members.json unreadable" --feature "$F" --to ses_b --type REQUEST --body x
}

test_invalid_members_refused() {
  echo '{not json' > "$F/members.json"
  refused_with "members.json unreadable" --feature "$F" --to ses_b --type REQUEST --body x
}

test_main_without_task_is_usage() {
  OPENCODE_SESSION_ID=ses_main assert_exit 1 "$SEND" --feature "$F" --to ses_a --type REQUEST --body x
}

run_test test_unknown_sender_refused
run_test test_main_is_member
run_test test_non_peer_refused
run_test test_self_send_refused
run_test test_missing_members_refused
run_test test_invalid_members_refused
run_test test_main_without_task_is_usage
summary
