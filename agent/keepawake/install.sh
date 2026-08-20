# keepawake — keep the Mac awake only while AI agents are working.
# Symlinks the CLI onto ~/.local/bin (where the Claude Code hooks and the
# LaunchAgent expect it), links the OpenCode plugin, and loads the 60s
# reconcile sweep. Idempotent.

set -e

DOTFILES="$HOME/.dotfiles"
BIN_SRC="$DOTFILES/agent/keepawake/keepawake"
BIN_LINK="$HOME/.local/bin/keepawake"
PLIST_SRC="$DOTFILES/agent/keepawake/com.sfdye.keepawake.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.sfdye.keepawake.plist"
PLUGIN_SRC="$DOTFILES/agent/keepawake/opencode-plugin.ts"
PLUGIN_DIR="$HOME/.config/opencode/plugins"
PLUGIN_LINK="$PLUGIN_DIR/keepawake.ts"

# macOS only — caffeinate is the mechanism.
[ "$(uname)" = "Darwin" ] || { echo "  keepawake: skipping (not macOS)"; exit 0; }

echo "› keepawake: linking CLI onto PATH"
mkdir -p "$HOME/.local/bin"
ln -sf "$BIN_SRC" "$BIN_LINK"

echo "› keepawake: linking OpenCode plugin"
mkdir -p "$PLUGIN_DIR"
ln -sf "$PLUGIN_SRC" "$PLUGIN_LINK"

echo "› keepawake: installing sweep LaunchAgent"
sed "s|__HOME__|$HOME|g" "$PLIST_SRC" > "$PLIST_DST"

# Reload the agent so changes take effect immediately.
launchctl bootout "gui/$(id -u)/com.sfdye.keepawake" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_DST" 2>/dev/null || true

echo "  keepawake installed. Run 'keepawake status' to inspect."
echo "  Note: Claude Code hooks live in ~/.claude/settings.json (not managed here)."
echo "  Note: OpenCode plugin auto-loads from ~/.config/opencode/plugins/ (symlinked above)."
