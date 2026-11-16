# Brief: ui

Feature: zero-balance-notice. Repository: ../ui. Branch: feat/balance-notice from main.

## Goal
Show a notice with a top-up link when `balance_exhausted` is true.

## Acceptance criteria (this task only)
- Notice component renders when the flag is true; generic error hidden.
- Nothing renders differently when the flag is false.

## You own
- `src/account/BalanceNotice.*`, `src/account/AccountPage.*`, their tests.

## Interfaces from other tasks
- contract.md "API": consume `balance_exhausted`; do not derive it from `balance`.

## Commands
- test: `npm test -- account`

## Report
Write to `.opencode/teamwork/zero-balance-notice/reports/ui.md`.
