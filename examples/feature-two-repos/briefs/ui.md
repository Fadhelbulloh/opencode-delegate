# Brief: ui

Feature: export-csv. Repository: ../ui. Branch: feat/export-link from main.

## Goal
Show a download link when `export_ready` is true.

## Acceptance criteria (this task only)
- Download link renders when the flag is true; spinner hidden.
- Nothing renders differently when the flag is false.

## You own
- `src/reports/DownloadLink.*`, `src/reports/ReportPage.*`, their tests.

## Interfaces from other tasks
- contract.md "API": consume `export_ready`; do not derive it from `status`.

## Commands
- test: `npm test -- reports`

## Report
Write to `.opencode/teamwork/export-csv/reports/ui.md`.
