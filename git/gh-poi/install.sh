# gh-poi-sweep — daily cleanup of merged/closed local branches and worktrees.
# Symlinks the script onto ~/.local/bin and loads the daily (3:07am) LaunchAgent.
# Idempotent.

set -e

DOTFILES="$HOME/.dotfiles"
BIN_SRC="$DOTFILES/git/gh-poi/gh-poi-sweep.sh"
BIN_LINK="$HOME/.local/bin/gh-poi-sweep"
PLIST_SRC="$DOTFILES/git/gh-poi/com.sfdye.gh-poi-sweep.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.sfdye.gh-poi-sweep.plist"

# macOS only — scheduled via launchd.
[ "$(uname)" = "Darwin" ] || { echo "  gh-poi-sweep: skipping (not macOS)"; exit 0; }

# Depends on the gh-poi extension; warn but don't fail the whole install run.
if command -v gh >/dev/null 2>&1; then
  gh extension list 2>/dev/null | grep -q 'seachicken/gh-poi' || {
    echo "› gh-poi-sweep: installing gh-poi extension"
    gh extension install seachicken/gh-poi || \
      echo "  gh-poi-sweep: note — failed to install gh-poi; run 'gh extension install seachicken/gh-poi'"
  }
else
  echo "  gh-poi-sweep: note — gh not found; install it, then run 'gh extension install seachicken/gh-poi'"
fi

echo "› gh-poi-sweep: linking script onto PATH"
mkdir -p "$HOME/.local/bin"
ln -sf "$BIN_SRC" "$BIN_LINK"

echo "› gh-poi-sweep: installing daily LaunchAgent"
sed "s|__HOME__|$HOME|g" "$PLIST_SRC" > "$PLIST_DST"

# Reload so schedule changes take effect immediately.
launchctl bootout "gui/$(id -u)/com.sfdye.gh-poi-sweep" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_DST" 2>/dev/null || true

echo "  gh-poi-sweep installed (runs daily 3:07am). Test now: gh-poi-sweep --dry-run"
