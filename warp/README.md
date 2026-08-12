# warp

[Warp](https://www.warp.dev) is the main terminal, replacing iTerm2.

## What's managed here, and what isn't

Warp has its own settings sync, so this topic only covers what sync leaves
behind. The two mechanisms are complementary — they don't overlap. Warp's
[file locations](https://docs.warp.dev/terminal/settings/file-locations) doc
sorts config into the same two buckets:

- **"Non-portable config" — `settings.toml`, not managed here.** Warp rewrites
  this file on every preference change and
  [settings sync](https://docs.warp.dev/terminal/more-features/settings-sync)
  roams it to your account, so versioning it would mean a dirty repo after every
  toggle plus two writers racing over one path. This repo already ran that
  experiment with iTerm2 — a long tail of "Update iterm pref" commits, then
  `Remove iterm pref` — and landed on delegating to the app's own sync.
- **"Portable user data" — `themes/`, `launch_configurations/`, `workflows/`,
  managed here.** Warp only ever *reads* these and sync explicitly does **not**
  carry custom themes or keybindings; the docs point at using a file instead.
  That makes them the `vimrc` case: hand-authored, versioned, symlinked in.
- **`keybindings.yaml` — managed here.** Warp files this under non-portable
  because sync won't roam it, which is exactly why the repo should: it's the
  only way to get the same bindings on a new machine.

`~/.warp/tab_configs/` is left alone despite being nominally portable — the one
on this machine is session-restore state with an absolute path baked in.

## Install

Handled by `script/install` (runs `warp/install.sh`), which symlinks
`keybindings.yaml` plus every `*.yaml` under `themes/`, `launch_configurations/`,
and `workflows/` into the matching `~/.warp/` subdirectory. Directories absent
from the repo are skipped, so adding `workflows/` later needs no script change.
An existing non-symlink `keybindings.yaml` is moved aside to `.backup` rather
than clobbered.

### On a fresh machine

Sign in to Warp **before** enabling settings sync. Enabling it pushes *that*
machine's settings to every other device — the docs are explicit that "the
settings from the computer you enabled it on becomes the default settings for all
devices" — so turning it on from a blank install overwrites your real config
everywhere.

Note that device-specific settings (preferred editor, startup shell) don't roam
even with sync on, and platform-scoped ones only roam between machines on the
same OS. Those are the settings you'll re-set by hand.

## Themes

The current theme is `adeberry`, which is **built into Warp** — there's no file
to version, just `theme = "adeberry"` under `[appearance.themes]` in
`settings.toml`. `themes/` is here for genuinely custom themes: drop a
`<name>.yaml` in, re-run `warp/install.sh`, and it appears in the theme picker.
Colors must be hex strings starting with `#`; `details` is `darker` or `lighter`
to mark the theme dark or light.

```yaml
name: Example
accent: "#8b5cf6"
background: "#1e1e2e"
foreground: "#cdd6f4"
details: darker
# cursor is optional and falls back to accent
terminal_colors:
  normal:
    black: "#45475a"
    red: "#f38ba8"
    green: "#a6e3a1"
    yellow: "#f9e2af"
    blue: "#89b4fa"
    magenta: "#f5c2e7"
    cyan: "#94e2d5"
    white: "#bac2de"
  bright:
    black: "#585b70"
    # ...same eight keys
```

Warp can take a few minutes — or a restart — to notice a newly created
`~/.warp/themes/` directory. After that, edits are picked up within seconds.
Warp's own [themes repo](https://github.com/warpdotdev/themes) has more to crib
from.

## Fonts

Fonts come from Homebrew casks in the `Brewfile` (`font-hack-nerd-font`,
`font-google-sans-code`, `font-fira-code`), not committed binaries — the old
`iterm/fonts/` directory of `.otf`/`.ttf` files was deleted with the iTerm topic.
`settings.toml` currently sets `font_name = "Hack"`.
