# warp — https://warp.dev, the main terminal (replaced iTerm2).
# Symlinks the hand-authored files Warp only ever *reads* (keybindings, custom
# themes) into ~/.warp. settings.toml is deliberately NOT managed here: Warp
# writes that file itself and syncs it to your account, so versioning it just
# produces churn — the same conclusion this repo reached for iTerm's prefs.
# Idempotent.

set -e

DOTFILES="$HOME/.dotfiles"
WARP_DIR="$HOME/.warp"

# macOS only — Warp has a Linux build, but the Brewfile installs the cask.
[ "$(uname)" = "Darwin" ] || { echo "  warp: skipping (not macOS)"; exit 0; }

[ -d "/Applications/Warp.app" ] || \
  echo "  warp: note — Warp.app not found; 'brew bundle' should install it"

mkdir -p "$WARP_DIR"

# Don't silently destroy keybindings that aren't ours.
KEYS_SRC="$DOTFILES/warp/keybindings.yaml"
KEYS_DST="$WARP_DIR/keybindings.yaml"
if [ -f "$KEYS_DST" ] && [ ! -L "$KEYS_DST" ]; then
  mv "$KEYS_DST" "$KEYS_DST.backup"
  echo "  warp: moved existing keybindings.yaml to keybindings.yaml.backup"
fi

echo "› warp: linking keybindings"
ln -sf "$KEYS_SRC" "$KEYS_DST"

# Warp calls these "portable user data" and settings sync does not carry them,
# so the repo does. Link files individually rather than the directories, so
# themes and workflows Warp downloads itself aren't clobbered. Missing dirs are
# skipped, so adding one later needs no change here.
for dir in themes launch_configurations workflows; do
  src_dir="$DOTFILES/warp/$dir"
  [ -d "$src_dir" ] || continue
  for f in "$src_dir"/*.yaml; do
    [ -e "$f" ] || continue
    mkdir -p "$WARP_DIR/$dir"
    echo "› warp: linking $dir/$(basename "$f")"
    ln -sf "$f" "$WARP_DIR/$dir/$(basename "$f")"
  done
done

echo "  warp installed. Settings live in ~/.warp/settings.toml (synced by Warp, not this repo)."
