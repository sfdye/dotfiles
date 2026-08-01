# gh-poi-sweep

Daily cleanup of merged/closed local branches (and their worktrees) across every
git repo under `~/Code`, delegating the per-repo decision to
[gh-poi](https://github.com/seachicken/gh-poi). This wrapper adds only what
gh-poi lacks: the recursive `~/Code` sweep and launchd scheduling.

Named `gh-poi-sweep` (not `gh-poi`) to avoid clashing with the `gh poi`
extension command it wraps.

`gh poi --state closed` deletes branches whose most recent linked PR is MERGED
or CLOSED. gh-poi never deletes the default branch, the checked-out branch, a
branch with uncommitted/untracked changes, or one whose worktree is locked, and
it removes a branch's worktree before deleting the branch.

## Install

Handled by `script/install` (runs `git/gh-poi/install.sh`), which
symlinks the script to `~/.local/bin/gh-poi-sweep` and loads a LaunchAgent
that runs it daily at 3:07am. Logs to `~/Library/Logs/gh-poi-sweep.log`.

Requires the gh-poi extension:

```sh
gh extension install seachicken/gh-poi
```

## Usage

```sh
gh-poi-sweep            # delete eligible branches + worktrees under ~/Code
gh-poi-sweep --dry-run  # report only, delete nothing
```

Override the sweep root with `GH_POI_SWEEP_ROOT` (defaults to `~/Code`).

## Caveat (accepted tradeoff)

gh-poi links a branch to a PR by commit heuristic and by branch name. For a
reused branch name it can match a stale merged PR and delete local-only commits
that were never integrated. Use `--dry-run` if unsure.
