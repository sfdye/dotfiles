# gh-poi-cleanup — daily cleanup of merged/closed local branches and worktrees.
# Symlinks the script onto ~/.local/bin and loads the daily (3:07am) LaunchAgent.
# Idempotent.

set -e

DOTFILES="$HOME/.dotfiles"
BIN_SRC="$DOTFILES/git/gh-poi-cleanup/gh-poi-cleanup.sh"
BIN_LINK="$HOME/.local/bin/gh-poi-cleanup"
PLIST_SRC="$DOTFILES/git/gh-poi-cleanup/com.lwan.gh-poi-cleanup.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.lwan.gh-poi-cleanup.plist"

# macOS only — scheduled via launchd.
[ "$(uname)" = "Darwin" ] || { echo "  gh-poi-cleanup: skipping (not macOS)"; exit 0; }

# Depends on the gh-poi extension; warn but don't fail the whole install run.
if command -v gh >/dev/null 2>&1; then
  gh extension list 2>/dev/null | grep -q 'seachicken/gh-poi' || \
    echo "  gh-poi-cleanup: note — run 'gh extension install seachicken/gh-poi'"
else
  echo "  gh-poi-cleanup: note — gh not found; install it and the gh-poi extension"
fi

echo "› gh-poi-cleanup: linking script onto PATH"
mkdir -p "$HOME/.local/bin"
ln -sf "$BIN_SRC" "$BIN_LINK"

echo "› gh-poi-cleanup: installing daily LaunchAgent"
sed "s|__HOME__|$HOME|g" "$PLIST_SRC" > "$PLIST_DST"

# Reload so schedule changes take effect immediately.
launchctl bootout "gui/$(id -u)/com.lwan.gh-poi-cleanup" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_DST" 2>/dev/null || true

echo "  gh-poi-cleanup installed (runs daily 3:07am). Test now: gh-poi-cleanup --dry-run"
