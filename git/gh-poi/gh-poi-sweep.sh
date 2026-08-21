#!/usr/bin/env bash
#
# gh-poi-sweep.sh — Daily cleanup of merged/closed local branches (and their
# worktrees) across every git repo under ~/Code, delegating the per-repo
# decision to gh-poi (github.com/seachicken/gh-poi).
#
# gh-poi removes a branch's associated worktree before deleting the branch, so
# this single script replaces the earlier worktree-cleanup.sh + branch-cleanup.sh
# pair. This wrapper only adds the parts gh-poi lacks: the recursive ~/Code sweep
# and (via launchd) scheduling.
#
# `--state closed` is a superset of merged: gh-poi deletes branches whose most
# recent linked PR is MERGED *or* CLOSED. gh-poi never deletes the default
# branch, the checked-out branch, a branch with uncommitted/untracked changes,
# or one whose worktree is locked.
#
# NOTE (accepted tradeoff): gh-poi links a branch to a PR by commit heuristic and
# by branch name. For a reused branch name it can match a stale merged PR and
# delete local-only commits that were never integrated. This was reviewed and
# accepted; the older branch-cleanup.sh kept such branches instead.
#
# Usage:
#   gh-poi-sweep.sh            # delete eligible branches + worktrees
#   gh-poi-sweep.sh --dry-run  # report only, delete nothing
#
set -uo pipefail

# launchd/cron run with a minimal PATH; ensure Homebrew bins (gh, git) resolve.
export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"

ROOT="${GH_POI_SWEEP_ROOT:-$HOME/Code}"
POI_ARGS=(--state closed)
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && { DRY_RUN=1; POI_ARGS+=(--dry-run); }

command -v gh  >/dev/null 2>&1 || { echo "ERROR: gh not found on PATH";  exit 1; }
command -v git >/dev/null 2>&1 || { echo "ERROR: git not found on PATH"; exit 1; }
# Capture first, then grep: `gh ext list | grep -q` under pipefail fails
# spuriously when grep -q closes the pipe early and gh dies with SIGPIPE.
ext_list="$(gh extension list 2>/dev/null)"
grep -q 'seachicken/gh-poi' <<<"$ext_list" || {
  echo "ERROR: gh-poi not installed — run: gh extension install seachicken/gh-poi"
  exit 1
}

repos=0
deleted=0
failed=0

# Count top-level branch names in gh-poi's "Deleted branches" section.
count_deleted() {
  awk '
    /^Deleted branches/ { g=1; next }
    /^[A-Za-z]/         { g=0 }          # next col-0 header ends the section
    g && /└─/           { next }         # PR sub-line
    g && /no branches/  { next }         # "There are no branches..."
    g {
      l=$0; sub(/^[[:space:]]+/, "", l)   # deleted branches are never the current branch, so no "* " marker
      if (l != "") n++
    }
    END { print n+0 }'
}

# Process substitution (not a pipe) keeps the loop in the current shell so the
# summary counters survive. A .git *directory* marks a main checkout; worktrees
# use a .git *file*, so this naturally targets only main checkouts (gh-poi run
# from the main checkout still tears down that repo's worktrees).
while read -r git_dir; do
  repo="$(dirname "$git_dir")"
  git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1 || continue
  repos=$((repos + 1))

  # Strip untracked/gitignored files (node_modules, build artifacts) from
  # .claude/worktrees/ so gh-poi's safety check doesn't block deletion of
  # worktrees whose PRs are already merged.
  wt_dir="$repo/.claude/worktrees"
  if [[ -d "$wt_dir" ]]; then
    while read -r wt; do
      [[ -d "$wt" ]] && git -C "$wt" clean -fdx </dev/null >/dev/null 2>&1
    done < <(find "$wt_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  fi

  # gh-poi runs in cwd; </dev/null guards against any unexpected prompt in the
  # TTY-less launchd environment.
  out="$(cd "$repo" && gh poi "${POI_ARGS[@]}" </dev/null 2>&1)"
  rc=$?

  # gh-poi's exit code is unreliable: it returns 0 even when an individual
  # `git branch -D` fails (e.g. a branch checked out mid-rebase), and on that
  # failure it also suppresses its "Deleted branches" summary. Detect trouble
  # by its output marker (a ✕ line or "failed to run") as well as rc, and ALWAYS
  # log a failing repo so it can never be silently omitted from the nightly log.
  if [[ $rc -ne 0 ]] || printf '%s\n' "$out" | grep -qE '^✕|failed to run'; then
    echo "Repo: $repo"
    echo "  ERROR  gh poi reported a failure (rc=$rc):"
    printf '%s\n' "$out" | sed 's/^/    /'
    failed=$((failed + 1))
    continue
  fi

  n="$(printf '%s\n' "$out" | count_deleted)"
  # Only log repos where something was (or would be) deleted, to keep the log
  # short — the vast majority of repos have nothing to do on any given day.
  if [[ "${n:-0}" -gt 0 ]]; then
    echo "Repo: $repo"
    printf '%s\n' "$out" \
      | awk '/^Deleted branches/{g=1} /^Branches not deleted/{g=0} g' \
      | sed 's/^/  /'
    deleted=$((deleted + n))
  fi
done < <(find "$ROOT" -type d \( -name node_modules -o -name .gradle -o -name build -o -name vendor \) -prune -o \
           -type d -name .git -print 2>/dev/null)

echo ""
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry run: $deleted branch(es) eligible across $repos repos, $failed repo error(s)."
else
  echo "Done: $deleted branch(es) deleted across $repos repos, $failed repo error(s)."
fi
