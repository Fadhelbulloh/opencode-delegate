# opencode-delegate

Planner and worker sessions for OpenCode v2. A planner session spawns background worker sessions, hands them tasks, and gets their reports back as queued prompts. No polling, no external server, only the OpenCode API.

Inspired by [MCP Bridge](https://mcpbridge.dev/), but for OpenCode sessions on one machine.

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

- Workers cannot spawn workers. Each worker is created with a `deny` rule for `opencode api session.create*`.
- Spawning a worker needs your confirmation: you pick the model and variant every time, and a global `ask` rule prompts before any session is created.
- Inbound messages are treated as data, not commands. The `[from ...]` sender is not verified.

## Install

Requires OpenCode v2 and `jq`.

1. Copy the skill and the plugin into your global config:

```bash
cp -r skills/delegate ~/.config/opencode/skills/
cp -r plugins/worker-tabs ~/.config/opencode/plugins/
```

2. Add the `ask` rule to `permissions` in `~/.config/opencode/opencode.json`:

```json
{ "action": "shell", "resource": "opencode api session.create*", "effect": "ask" }
```

3. Register the TUI plugin in `~/.config/opencode/cli.json`, using the absolute path to your home:

```json
"plugins": [{ "package": "/Users/<you>/.config/opencode/plugins/worker-tabs" }]
```

4. Restart the TUI.

## Usage

In any session, ask: "use the delegate skill to spawn a worker for <task>". Pick a model and variant when asked.

The default shortlist is the planner's own model plus three models from the author's setup. Edit the shortlist in `skills/delegate/SKILL.md` to match the models you have.

## Limits

- No delivery acknowledgement. If the planner session is deleted, worker reports are lost silently.
- No message IDs. One open question per worker at a time.
- The worker needs shell access to run `opencode api`.

## License

MIT
