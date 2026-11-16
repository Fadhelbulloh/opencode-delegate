# Contract: export-csv

Single editor: ses_main. Others propose changes with a REQUEST.

## API
| method | path | request | response | errors |
| --- | --- | --- | --- | --- |
| GET | /v1/reports/{id} | — | `{ id, status: string, export_ready: boolean }` | 401, 404 |

## Agreed between workers
- 2026-01-10 ses_api/ses_ui: `export_ready` is derived server-side from file existence; UI never computes it from `status`.
