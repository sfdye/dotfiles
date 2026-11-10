# agent

Utilities for working with AI coding agents (Claude Code, Cursor, Codex, …).

Each tool is a **self-contained subdirectory** with its own `install.sh`, which
`script/install` auto-discovers via `find . -name install.sh`. To add a new
tool, drop in `agent/<tool>/` with an `install.sh` — nothing central to edit.

Shell-level pieces follow the usual topic conventions and are picked up wherever
they live under here: `*.zsh` files are sourced on shell start (`aliases.zsh`
for agent shortcuts), `path.zsh` first, `completion.zsh` last.

## Tools

(none yet)
