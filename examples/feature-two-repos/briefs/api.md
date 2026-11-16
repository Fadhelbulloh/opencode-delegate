# Brief: api

Feature: zero-balance-notice. Repository: ../api. Branch: feat/balance-exhausted from main.

## Goal
Add `balance_exhausted` to the account response.

## Acceptance criteria (this task only)
- `GET /v1/account` returns `balance_exhausted: true` when balance is 0, `false` otherwise.
- Field is always present.

## You own
- `src/account/serializer.*`, `src/account/handler.*`, their tests.

## Interfaces from other tasks
- contract.md "API": response shape; the UI task consumes it.

## Commands
- test: `npm test -- account`

## Report
Write to `.opencode/teamwork/zero-balance-notice/reports/api.md`.
