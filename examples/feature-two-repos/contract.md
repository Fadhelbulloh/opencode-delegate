# Contract: zero-balance-notice

Single editor: ses_main. Others propose changes with a REQUEST.

## API
| method | path | request | response | errors |
| --- | --- | --- | --- | --- |
| GET | /v1/account | — | `{ id, balance: number, balance_exhausted: boolean }` | 401 |

## Agreed between workers
- 2026-01-10 ses_api/ses_ui: `balance_exhausted` is derived server-side; UI never computes it from `balance`.
