# keepawake

Keep the Mac awake **only while AI agents are actually working** — then let it
sleep normally. A dependency-light reimplementation of the *design* of
[adrafinil](https://github.com/kageroumado/adrafinil): hook-driven
acquire/release, reference-counted holds, and a self-healing sweep — but as a
shell CLI plus Claude Code hooks. No menu-bar app, no root daemon.

Built because some managed Macs block GUI keep-awake apps (Caffeine,
Amphetamine); this uses only the built-in `caffeinate` binary and a per-user
LaunchAgent, so it needs no admin rights.

## How it works

- Each "hold" is a file under `~/.local/state/keepawake/holds/`. While ≥1 valid
  hold exists, one `caffeinate -i -m` runs (blocks idle **system** sleep). Zero
  holds → normal sleep.
- Holds are reference-counted: overlapping agent sessions stack; sleep unblocks
  only when the last one releases.
- `keepawake sweep` (run every 60s by the LaunchAgent) reconciles desired vs.
  actual state, so missed releases, dead sessions, expired holds, and reboots
  all self-heal.

## Install

Handled by `script/install` (runs `agent/keepawake/install.sh`), which symlinks the
CLI to `~/.local/bin/keepawake` and loads the sweep LaunchAgent.

Then wire Claude Code to drive it — add to `~/.claude/settings.json` (not
managed in this repo, as it holds machine-specific secrets):

```jsonc
"hooks": {
  "UserPromptSubmit": [{ "hooks": [{ "type": "command",
    "command": "input=$(cat); sid=$(printf %s \"$input\" | jq -r \".session_id // \\\"default\\\"\" 2>/dev/null || echo default); keepawake acquire \"claude-$sid\" --reason \"claude code\" >/dev/null 2>&1 || true" }] }],
  "Stop": [{ "hooks": [{ "type": "command",
    "command": "input=$(cat); sid=$(printf %s \"$input\" | jq -r \".session_id // \\\"default\\\"\" 2>/dev/null || echo default); keepawake release \"claude-$sid\" >/dev/null 2>&1 || true" }] }],
  "Notification": [{ "matcher": "permission_prompt", "hooks": [{ "type": "command",
    "command": "input=$(cat); sid=$(printf %s \"$input\" | jq -r \".session_id // \\\"default\\\"\" 2>/dev/null || echo default); keepawake acquire \"claude-$sid\" --reason \"awaiting permission\" >/dev/null 2>&1 || true" }] }]
}
```

`UserPromptSubmit` acquires when a turn starts, `Stop` releases when it ends,
and the `permission_prompt` notification keeps the Mac awake while Claude waits
on your approval. (`Stop` doesn't fire on Esc-abort or API errors — the 60s
sweep is the safety net for those.)

Requires `jq` (used by the hooks to parse `session_id` from stdin).

### OpenCode

`install.sh` also symlinks `opencode-plugin.ts` into
`~/.config/opencode/plugins/keepawake.ts`, which OpenCode auto-discovers at
startup — no `opencode.json` change needed. The plugin subscribes to session
events and drives the same `keepawake acquire/release` CLI:

- `session.status` busy/retry → `keepawake acquire opencode-<sessionID> --reason opencode`
- `session.status` idle, `session.idle`, `session.deleted` → `keepawake release opencode-<sessionID>`

Permission prompts need no special handling: the session stays `busy` while a
prompt is open, so the busy-hold covers the wait. Crashes / `kill -9` self-heal
via the 60s sweep (dead-pid prune), same as Claude Code. Holds are keyed by
session ID, so overlapping sessions (e.g. a subagent alongside the parent)
reference-count correctly under one `caffeinate`.

## Usage

```sh
keepawake status              # what's holding the Mac awake, and why
keepawake on --for 2h         # manual hold for a non-agent job (build, download)
keepawake off                 # clear the manual hold
keepawake acquire <key> [--reason r] [--for 30m]
keepawake release <key>
keepawake sweep               # reconcile (the LaunchAgent runs this every 60s)
```

## Clamshell (lid-closed) — not supported by design

`caffeinate` / public `IOPMAssertion` types **cannot** prevent lid-closed sleep;
only `sudo pmset disablesleep 1` (root) can. There's a `keepawake clamshell on`
path that toggles it via a non-interactive sudo, gated on a narrowly-scoped
`/etc/sudoers.d` grant — but on MDM-managed Macs a management profile typically
reverts `disablesleep`, making clamshell impossible from userspace regardless.
Left off by default. Lid-open, unattended runs are fully covered.
