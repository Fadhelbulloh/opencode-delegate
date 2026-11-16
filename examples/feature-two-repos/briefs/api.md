# Brief: api

Feature: export-csv. Repository: ../api. Branch: feat/export-ready from main.

## Goal
Add `export_ready` to the report response.

## Acceptance criteria (this task only)
- `GET /v1/reports/{id}` returns `export_ready: true` when the export file exists, `false` otherwise.
- Field is always present.

## You own
- `src/reports/serializer.*`, `src/reports/handler.*`, their tests.

## Interfaces from other tasks
- contract.md "API": response shape; the UI task consumes it.

## Commands
- test: `npm test -- reports`

## Report
Write to `.opencode/teamwork/export-csv/reports/api.md`.
