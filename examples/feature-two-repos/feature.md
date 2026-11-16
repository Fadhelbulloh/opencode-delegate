# Feature: zero-balance-notice

## Goal
When an account balance reaches zero, the API returns a `balance_exhausted` flag and the UI shows a notice with a top-up link instead of a generic error.

## Acceptance criteria
- `GET /v1/account` includes `balance_exhausted: true` when balance is 0.
- The UI renders the notice component and hides the generic error when the flag is set.
- Existing account tests pass in both repositories.

## Repositories
| repo | path | integration branch | baseline commit |
| --- | --- | --- | --- |
| api | ../api | main | 1111111 |
| ui | ../ui | main | 2222222 |

## Contract editor
ses_main

## Decisions
- 2026-01-10: flag name `balance_exhausted`, boolean, always present — simpler for the UI than a nullable reason string.
