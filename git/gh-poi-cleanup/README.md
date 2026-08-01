# gh-poi-cleanup

Daily cleanup of merged/closed local branches (and their worktrees) across every
git repo under `~/Code`, delegating the per-repo decision to
[gh-poi](https://github.com/seachicken/gh-poi). This wrapper adds only what
gh-poi lacks: the recursive `~/Code` sweep and launchd scheduling.

`gh poi --state closed` deletes branches whose most recent linked PR is MERGED
or CLOSED. gh-poi never deletes the default branch, the checked-out branch, a
branch with uncommitted/untracked changes, or one whose worktree is locked, and
it removes a branch's worktree before deleting the branch.

## Install

Handled by `script/install` (runs `git/gh-poi-cleanup/install.sh`), which
symlinks the script to `~/.local/bin/gh-poi-cleanup` and loads a LaunchAgent
that runs it daily at 3:07am. Logs to `~/Library/Logs/gh-poi-cleanup.log`.

Requires the gh-poi extension:

```sh
gh extension install seachicken/gh-poi
```

## Usage

```sh
gh-poi-cleanup            # delete eligible branches + worktrees under ~/Code
gh-poi-cleanup --dry-run  # report only, delete nothing
```

Override the sweep root with `GH_POI_CLEANUP_ROOT` (defaults to `~/Code`).

## Caveat (accepted tradeoff)

gh-poi links a branch to a PR by commit heuristic and by branch name. For a
reused branch name it can match a stale merged PR and delete local-only commits
that were never integrated. Use `--dry-run` if unsure.
