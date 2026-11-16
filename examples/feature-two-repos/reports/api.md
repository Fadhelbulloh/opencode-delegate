# Report: api

## Status
DONE — flag added, review verified.

## Commits
- 3333333 feat: add export_ready to report response
- 4444444 fix: export_ready false while file is still being written

## Checks run
- `npm test -- reports` → 14 passed

## Findings addressed
- Partially written file reported `true` → check for the `.done` marker, commit 4444444

## Open notes
- Serializer could share the file-check helper with the attachments module.

## Manual prompts received
(none)
