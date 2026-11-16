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

## Install

Requires **OpenCode v2**, **Git**, and **jq**. Tested with OpenCode **v2.0.28**.

1. Copy the skill and the plugin into your global config:

```bash
git clone https://github.com/Fadhelbulloh/opencode-delegate.git
cd opencode-delegate

mkdir -p ~/.config/opencode/skills ~/.config/opencode/plugins
cp -r skills/delegate ~/.config/opencode/skills/
cp -r plugins/worker-tabs ~/.config/opencode/plugins/
```

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
| [plugins/worker-tabs/tui.ts](plugins/worker-tabs/tui.ts) | Opens tabs for new sessions tagged as workers |

## Limits

- API acceptance does not confirm that the planner processed a report. Sending to a deleted planner fails; the skill has no retry or acknowledgement workflow.
- Labels provide reply context, but there is no thread manager. Keep one open question per worker at a time.
- The worker needs shell access to run `opencode api`.
- Workers share the planner's directory. Coordinate file ownership for parallel tasks; the skill does not create isolated worktrees.
- The tab plugin opens any new worker whose creation event reaches that TUI. It does not filter by planner.
