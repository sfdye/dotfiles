# warp

[Warp](https://www.warp.dev) is the main terminal, replacing iTerm2.

## What's managed here, and what isn't

Warp has its own settings sync, so this topic only covers what sync leaves
behind. The two mechanisms are complementary — they don't overlap.

- **`settings.toml` — not managed here.** Warp rewrites this file on every
  preference change and
  [settings sync](https://docs.warp.dev/terminal/more-features/settings-sync)
  roams it to your account, so versioning it would mean a dirty repo after every
  toggle plus two writers racing over one path. This repo already ran that
  experiment with iTerm2 — a long tail of "Update iterm pref" commits, then
  `Remove iterm pref` — and landed on delegating to the app's own sync.
- **`keybindings.yaml` and `themes/*.yaml` — managed here.** Warp only ever
  *reads* these, and sync explicitly does **not** carry custom keybindings or
  themes; the docs point at using a file instead. That makes them the `vimrc`
  case: hand-authored, versioned, symlinked in.

`~/.warp/tab_configs/` is left alone despite being nominally portable — the one
on this machine is session-restore state with an absolute path baked in.

## Install

Handled by `script/install`, which runs `warp/install.sh`. An existing
non-symlink `~/.warp/keybindings.yaml` is moved aside to `.backup` rather than
clobbered.

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
to version. For a genuinely custom theme, add `warp/themes/<name>.yaml` and
re-run `warp/install.sh`; Warp's
[custom themes docs](https://docs.warp.dev/terminal/appearance/custom-themes)
have the schema and its own
[themes repo](https://github.com/warpdotdev/themes) has plenty to crib from.
Warp can take a restart to notice `~/.warp/themes/` the first time it appears;
after that, edits are picked up within seconds.

## Fonts

Fonts come from Homebrew casks in the `Brewfile` (`font-hack-nerd-font`,
`font-google-sans-code`, `font-fira-code`), not committed binaries.
