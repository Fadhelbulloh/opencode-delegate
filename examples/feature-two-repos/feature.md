# Feature: export-csv

## Goal
When a report export has finished, the API returns an `export_ready` flag and the UI shows a download link instead of a spinner.

## Acceptance criteria
- `GET /v1/reports/{id}` includes `export_ready: true` when the export file exists.
- The UI renders the download link and hides the spinner when the flag is set.
- Existing report tests pass in both repositories.

## Repositories
| repo | path | integration branch | baseline commit |
| --- | --- | --- | --- |
| api | ../api | main | 1111111 |
| ui | ../ui | main | 2222222 |

## Contract editor
ses_main

## Decisions
- 2026-01-10: flag name `export_ready`, boolean, always present — simpler for the UI than a nullable status string.
