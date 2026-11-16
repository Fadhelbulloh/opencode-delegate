# Report: api

## Status
DONE — flag added, review verified.

## Commits
- 3333333 feat: add balance_exhausted to account response
- 4444444 fix: balance_exhausted true for negative balance

## Checks run
- `npm test -- account` → 14 passed

## Findings addressed
- Negative balance returned `false` → compare `<= 0`, commit 4444444

## Open notes
- Serializer could share the balance helper with the invoice module.

## Manual prompts received
(none)
