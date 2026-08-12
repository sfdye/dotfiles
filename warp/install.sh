# warp — https://warp.dev, the main terminal (replaced iTerm2).
# Symlinks the files Warp only ever *reads* (keybindings, custom themes) into
# ~/.warp. settings.toml is deliberately NOT managed here: Warp writes that file
# itself and syncs it to your account, so versioning it just produces churn —
# the same conclusion this repo reached for iTerm's prefs. Idempotent.

set -e

DOTFILES="$HOME/.dotfiles"
WARP_DIR="$HOME/.warp"
KEYS_SRC="$DOTFILES/warp/keybindings.yaml"
KEYS_DST="$WARP_DIR/keybindings.yaml"

# macOS only — Warp has a Linux build, but the Brewfile installs the cask.
[ "$(uname)" = "Darwin" ] || { echo "  warp: skipping (not macOS)"; exit 0; }

mkdir -p "$WARP_DIR"

# Don't silently destroy keybindings that aren't ours.
if [ -f "$KEYS_DST" ] && [ ! -L "$KEYS_DST" ]; then
  mv "$KEYS_DST" "$KEYS_DST.backup"
  echo "  warp: moved existing keybindings.yaml to keybindings.yaml.backup"
fi

echo "› warp: linking keybindings"
ln -sf "$KEYS_SRC" "$KEYS_DST"

# Settings sync doesn't carry custom themes, so the repo does. Link the files
# rather than the directory, so themes Warp downloads itself survive.
set -- "$DOTFILES"/warp/themes/*.yaml
if [ -e "$1" ]; then
  echo "› warp: linking themes"
  mkdir -p "$WARP_DIR/themes"
  ln -sf "$@" "$WARP_DIR/themes/"
fi

echo "  warp installed. Settings live in ~/.warp/settings.toml (synced by Warp, not this repo)."
