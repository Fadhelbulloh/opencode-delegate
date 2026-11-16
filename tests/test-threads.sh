#!/bin/sh
. "$(dirname "$0")/lib.sh"

as() { # as <session> <args...>
  _s=$1; shift
  OPENCODE_SESSION_ID=$_s "$SEND" --feature "$F" "$@" >/dev/null 2>&1
}

refused() { # refused <reason> <session> <args...>
  _want=$1; shift
  as "$@"; _rc=$?
  [ "$_rc" = 2 ] || { echo "  exit $_rc, want 2"; return 1; }
  _r=$(ledger_last "$F" | jq -r .reason)
  [ "$_r" = "$_want" ] || { echo "  reason [$_r] want [$_want]"; return 1; }
}

test_duplicate_msg_id_refused() {
  as ses_a --msg X --to ses_b --type REQUEST --body q || return 1
  refused "duplicate msg id" ses_a --msg X --to ses_b --type REQUEST --body q
}

test_reply_closes_request() {
  as ses_a --msg X --to ses_b --type REQUEST --body q || return 1
  as ses_b --to ses_a --type REPLY --re X --body a || return 1
  refused "request already answered" ses_b --to ses_a --type REPLY --re X --body a
}

test_reply_from_wrong_session_refused() {
  as ses_a --msg X --to ses_b --type REQUEST --body q || return 1
  refused "no open request X for you" ses_main --task api --to ses_a --type REPLY --re X --body a
}

test_reply_to_status_refused() {
  as ses_a --msg Y --to ses_b --type STATUS --status INFO --body i || return 1
  refused "cannot reply to STATUS" ses_b --to ses_a --type REPLY --re Y --body a
}

test_second_open_request_same_pair() {
  as ses_a --to ses_b --type REQUEST --body q1 || return 1
  refused "open request to recipient exists" ses_a --to ses_b --type REQUEST --body q2
}

test_new_request_after_reply_allowed() {
  as ses_a --msg X --to ses_b --type REQUEST --body q || return 1
  as ses_b --to ses_a --type REPLY --re X --body a || return 1
  as ses_a --to ses_b --type REQUEST --body q2
}

test_reply_without_re_refused() {
  refused "reply needs --re" ses_b --to ses_a --type REPLY --body a
}

test_reply_to_unknown_id_refused() {
  refused "no open request NOPE for you" ses_b --to ses_a --type REPLY --re NOPE --body a
}

run_test test_duplicate_msg_id_refused
run_test test_reply_closes_request
run_test test_reply_from_wrong_session_refused
run_test test_reply_to_status_refused
run_test test_second_open_request_same_pair
run_test test_new_request_after_reply_allowed
run_test test_reply_without_re_refused
run_test test_reply_to_unknown_id_refused
summary
