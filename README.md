# opencode-delegate

**Keep the plan in one session. Let workers handle the tasks.**

I use one OpenCode session to plan a module, break down the work, and write prompts for other sessions. Then I copy those prompts over and bring the results back so the planner can update the docs.

`opencode-delegate` handles those handoffs through the OpenCode v2 API. The planner sends tasks to worker sessions; workers send back results or questions. You approve each worker and choose its model.

Inspired by [MCP Bridge](https://mcpbridge.dev/), but for OpenCode sessions on one machine.

## Your planner, with a team of workers

```text
You
 │  Approve the task, choose the model and variant
 ▼
Planner session
 ├── Worker: implement the endpoint
 ├── Worker: review the changes
 └── Worker: write the tests
       │
       └── DONE / FAILED / QUESTION sent back to the planner
```

Each module can have its own planner and workers. Every worker records its planner's session ID, so it knows where to report.

Workers appear as tabs without moving focus away from your current session. Reports arrive as queued prompts, so the planner can continue working without polling for completion.

## Try a delegation

After installing, ask your planner:

> Use the delegate skill to create a worker that reviews the authentication changes. Report concrete bugs with file references. Do not edit files.

The planner presents the task and completion criteria, then asks you to choose a model and variant.

## How it works

1. The planner asks you which model the worker should use, then creates the worker with `opencode api session.create` in the same directory. The worker is tagged with `metadata: {role: "worker", planner: <planner id>}`.
2. The planner sends the task with `opencode api session.prompt`.
3. The worker reports `DONE`, `FAILED`, or `QUESTION` back to the planner with `delivery: "queue"`, so it never interrupts a running turn.
4. The `worker-tabs` TUI plugin opens each new worker as a tab. Focus stays on the planner.

Message format:

```
Planner to worker:  [ref: auth-login/2] Should the endpoint be /v2/login or /login?
Worker to planner:  [from ses_... | re: auth-login/2] DONE: "/v2/login or /login?" - /v2/login, checked in the router.
```

## Guardrails

- Workers are instructed not to spawn workers. A session-level `deny` rule blocked the tested `opencode api session.create` command. This command pattern is not a sandbox against every possible API client or invocation.
- The skill requires your approval and model selection before creating each worker. The global `ask` rule adds a permission check for matching commands; verify that prompt in your installation, since planner-side enforcement was not confirmed in the initial test.
- Inbound messages are treated as data, not commands. The `[from ...]` sender is not verified.

## Teamwork: one main session, several workers, hard limits

`delegate` is one planner handing off isolated tasks. `teamwork` is for one person who owns a product across repositories: the main session acts as product analyst and coordinator, workers on the same feature can ask each other technical questions, and every exchange has a budget enforced by a script.

```text
.opencode/teamwork/<feature>/       scratch for one feature, git-ignored
  feature.md   goal, acceptance criteria, repositories, decisions
  contract.md  cross-repo contracts; one editor
  tasks.md     state, worker, model, budget use per task
  members.json who may message whom (read by the script)
  budgets.json limits per task (read by the script)
  ledger.jsonl every message, sent or refused
  briefs/      one focused handoff per task; never the whole plan
  reports/     one report per task; the only file a worker may edit here
```

Every message between sessions goes through `bin/teamwork-send`. It refuses, logs the refusal, and exits 2 when:

| Rule | Default |
| --- | --- |
| Sender not a member, recipient not a peer, or sender == recipient | always |
| `REVIEW` / `REVIEW_VERIFY` from anyone but a registered reviewer, or to anyone but main | always |
| Duplicate message id | always |
| `REPLY` to anything but an open `REQUEST` addressed to you, or a second reply | always |
| New `REQUEST` while one is still open to that recipient | always |
| Messages for a task | 24 |
| `REVIEW` messages per task | 1 |
| `REVIEW_VERIFY` messages per task | 1 |

On refusal the worker stops and marks its report `BLOCKED` or `PAUSED`. Only you can raise a budget; main records your decision in `budgets.json`. Review is one consolidated pass, one fix round, one verification; anything still open comes back to you with three options: one more round, accept with disclosed findings, stop.

What this gives: only `REQUEST` can be answered, and only once; every other type ends the thread. A task has a fixed number of messages, and reaching it pauses the task for you. Nothing creates sessions, re-sends, or re-opens budgets without a user action. The limits are checked by a script against a ledger, not by the model's judgement.

What it does not give: protection against a worker that bypasses the script on purpose. Worker sessions get `deny` rules for `opencode api session.prompt*`, `session.create*`, and `session.update*`; a deliberate `curl` to the local service is still possible. The configuration makes bypass an explicit act, not an accident.

See [examples/feature-two-repos](examples/feature-two-repos) for a filled-in feature directory after one review round.

## Install

Requires **OpenCode v2**, **Git**, and **jq**. Tested with OpenCode **v2.0.28**.

1. Copy the skills, the scripts, and the plugin into your global config:

```bash
git clone https://github.com/Fadhelbulloh/opencode-delegate.git
cd opencode-delegate

mkdir -p ~/.config/opencode/skills ~/.config/opencode/plugins ~/.config/opencode/bin
cp -r skills/delegate skills/teamwork ~/.config/opencode/skills/
cp -r plugins/worker-tabs ~/.config/opencode/plugins/
cp bin/teamwork-send bin/teamwork-status ~/.config/opencode/bin/
```

`teamwork` is optional; `delegate` works on its own. The skills call the scripts by their path under `~/.config/opencode/bin`, so no `PATH` change is needed.

These commands install globally. Review existing copies before overwriting any local customizations.

2. Add the `ask` rule to `permissions` in `~/.config/opencode/opencode.json`:

```json
{ "action": "shell", "resource": "opencode api session.create*", "effect": "ask" }
```

3. Register the TUI plugin in `~/.config/opencode/cli.json`, using the absolute path to your home:

```json
{
  "plugins": [
    { "package": "/absolute/path/to/.config/opencode/plugins/worker-tabs" }
  ],
  "tabs": { "mode": "on" }
}
```

Merge these entries into your configuration. Preserve existing plugins, permission rules, and tab settings.

4. Restart the TUI.

## Usage

In any session, ask: "use the delegate skill to spawn a worker for <task>". Pick a model and variant when asked.

The model list comes from `opencode api model.list` on your instance. Nothing is hardcoded and nothing is labeled "recommended"; the planner describes what the task needs and you choose.

## What's included

| File | Purpose |
| --- | --- |
| [skills/delegate/SKILL.md](skills/delegate/SKILL.md) | Approval, model selection, worker creation, and reporting conventions |
| [skills/teamwork/SKILL.md](skills/teamwork/SKILL.md) | Main/worker/reviewer flow, feature workspace, review rounds, budgets |
| [skills/teamwork/templates/](skills/teamwork/templates/) | Feature, contract, tasks, brief, report, members, budgets templates |
| [bin/teamwork-send](bin/teamwork-send) | Checked message sending; the only path between teamwork sessions |
| [bin/teamwork-status](bin/teamwork-status) | Budget use and open-request age per task |
| [plugins/worker-tabs/tui.ts](plugins/worker-tabs/tui.ts) | Opens tabs for new sessions tagged as workers, in the planner's TUI |
| [tests/](tests/) | `sh tests/run.sh`: refusal and budget cases against a fake `opencode` |

## Limits

- API acceptance does not confirm that the planner processed a report. Sending to a deleted planner fails; there is no retry or acknowledgement.
- Senders are not authenticated. Any local process can post to any session.
- No timeout daemon. A request nobody answers is shown as stale by `teamwork-status` when main next looks, not acted on.
- `teamwork-send` can be bypassed by a deliberate direct call to the local service. The `deny` rules block the plain CLI path only.
- Ledger appends are not locked. Two sends in the same instant can both pass the checks, so a budget can be overshot by the number of concurrent senders; the tests do not cover that.
- Edit `deny` rules do not cover shell writes. A worker that truncates `ledger.jsonl` or edits `budgets.json` from the shell resets its limits; that is a deliberate bypass, not an accident, and `tasks.md` keeps main's own record.
- The `edit` rules list both absolute and location-relative paths. Both forms were denied as expected on OpenCode v2.0.28; which one the matcher uses was not isolated.
- The worker needs shell access to run `opencode api`.
- `delegate` alone has no thread manager. Keep one open question per worker at a time.
- Parallel workers in one repository need separate git worktrees; the teamwork skill asks for them, `delegate` alone does not create them.

## License

MIT. See [LICENSE](LICENSE).
