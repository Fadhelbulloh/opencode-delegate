# Changelog

## 0.2.2

- `delegate`: planner offers at most 5 models suited to the task, with a reason each, instead of every model on the instance.
- Install: global rule for `opencode api session.create*` is `allow` (was `ask`); the planner spawns without a second prompt. Workers keep their session-level `deny`.

## 0.2.1

- README introduces both skills up front.

## 0.2.0

- `teamwork` skill: one main session coordinates workers on one feature across repositories.
- `bin/teamwork-send`: the only sanctioned message path; refuses non-peers, duplicate ids, second replies, concurrent open requests, and anything over the task or review budget.
- `bin/teamwork-status`: budget use and open-request age per task.
- `delegate`: model list comes from `opencode api model.list`; no hardcoded shortlist, nothing labeled recommended. Spawn snippet accepts `DIR`, `EXTRA`, `META`.
- `worker-tabs`: matches on `metadata.home` so workers in git worktrees open in the planner's TUI.
- `LICENSE` (MIT), `examples/feature-two-repos`, `tests/`.

## 0.1.0

- `delegate` skill and `worker-tabs` TUI plugin.
