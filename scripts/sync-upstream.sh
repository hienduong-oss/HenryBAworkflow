#!/usr/bin/env bash
# sync-upstream.sh
# Fetch updates from upstream (anhdam2/bakit), merge if clean, push to origin.
# Usage: ./sync-upstream.sh [--dry-run]

set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
  echo "[dry-run] No changes will be made"
fi

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="main"
ORIGIN_REMOTE="origin"

# ─── helpers ─────────────────────────────────────────────────────────────────
info()  { echo "ℹ️  $1"; }
warn()  { echo "⚠️  $1"; }
fail()  { echo "❌ $1" >&2; exit 1; }

git_cmpl() { git -C "${REPO}" "$@"; }

has_changes() {
  [[ -n "$(git_cmpl status --short)" ]]
}

get_log() {
  local base="$1"
  git_cmpl log --oneline "${base}..HEAD" 2>/dev/null || echo "(none)"
}

# ─── pre-flight ───────────────────────────────────────────────────────────────
cd "${REPO}"

if ! git_cmpl rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  fail "Not a git repository: ${REPO}"
fi

if ! git_cmpl remote get-url "${UPSTREAM_REMOTE}" >/dev/null 2>&1; then
  fail "No '${UPSTREAM_REMOTE}' remote configured.
  Add with: git remote add upstream https://github.com/anhdam2/bakit.git"
fi

# ─── fetch upstream ──────────────────────────────────────────────────────────
info "Fetching upstream..."
git_cmpl fetch "${UPSTREAM_REMOTE}"

UPSTREAM_REF="${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}"
LOCAL_HEAD="$(git_cmpl rev-parse HEAD)"
UPSTREAM_HEAD="$(git_cmpl rev-parse "${UPSTREAM_REF}")"

if [[ "${LOCAL_HEAD}" == "${UPSTREAM_HEAD}" ]]; then
  info "Already up-to-date with upstream (${UPSTREAM_HEAD:0:7}). Nothing to do."
  exit 0
fi

# ─── analyze diff ────────────────────────────────────────────────────────────
UPSTREAM_AHEAD="$(git_cmpl log --oneline HEAD.."${UPSTREAM_REF}" 2>/dev/null | wc -l | tr -d ' ')"
LOCAL_AHEAD="$(git_cmpl log --oneline "${UPSTREAM_REF}"..HEAD 2>/dev/null | wc -l | tr -d ' ')"

echo ""
echo "══════════════════════════════════════════════════"
echo "  Upstream vs Local"
echo "══════════════════════════════════════════════════"
echo "  Upstream has ${UPSTREAM_AHEAD} commit(s) newer than local"
echo "  Local has   ${LOCAL_AHEAD} commit(s) newer than upstream"
echo "══════════════════════════════════════════════════"
echo ""

if [[ "${LOCAL_AHEAD}" -gt 0 ]]; then
  echo "  Your local commits:"
  git_cmpl log --oneline "${UPSTREAM_REF}"..HEAD | sed 's/^/    /'
  echo ""
fi

# ─── case 1: clean fast-forward (upstream only has new commits) ────────────
if [[ "${LOCAL_AHEAD}" -eq 0 ]]; then
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "[dry-run] Would fast-forward merge ${UPSTREAM_REF} → HEAD"
    exit 0
  fi

  info "Fast-forward merge from upstream..."
  git_cmpl pull --ff-only || fail "Fast-forward failed. Check git status."

  info "Pushing to origin..."
  git_cmpl push "${ORIGIN_REMOTE}" "${UPSTREAM_BRANCH}"

  echo ""
  info "✓ Update complete."
  info "  Before: $(git_cmpl rev-parse --short "${UPSTREAM_HEAD}")"
  info "  After:  $(git_cmpl rev-parse --short HEAD)"
  exit 0
fi

# ─── case 2: diverged (both have new commits) ─────────────────────────────
if [[ "${LOCAL_AHEAD}" -gt 0 && "${UPSTREAM_AHEAD}" -gt 0 ]]; then
  echo "══════════════════════════════════════════════════"
  echo "  ⚠️  DIVERGED — manual resolution required"
  echo "══════════════════════════════════════════════════"
  echo ""
  echo "  Upstream changes:"
  git_cmpl log --oneline HEAD.."${UPSTREAM_REF}" | sed 's/^/    /'
  echo ""
  echo "  Your local changes:"
  git_cmpl log --oneline "${UPSTREAM_REF}"..HEAD | sed 's/^/    /'
  echo ""
  echo "Conflict candidates (same file modified):"
  git_cmpl diff --name-only "${UPSTREAM_REF}" HEAD | while read -r f; do
    if git_cmpl diff --exit-code "${UPSTREAM_REF}" HEAD -- "$f" >/dev/null 2>&1; then
      echo "    CONFLICT: $f"
    fi
  done

  echo ""
  echo "Options:"
  echo "  1) Rebase your changes on upstream:"
  echo "       git rebase ${UPSTREAM_REF}"
  echo "  2) Merge upstream into local (may auto-resolve):"
  echo "       git merge ${UPSTREAM_REF}"
  echo "  3) Discard local changes and reset to upstream:"
  echo "       git reset --hard ${UPSTREAM_REF}"
  echo ""
  echo "After resolving, push with:"
  echo "  git push ${ORIGIN_REMOTE} ${UPSTREAM_BRANCH}"
  echo ""

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "[dry-run] Would stop here for manual resolution"
    exit 0
  fi

  # List conflicting files for user
  conflict_files=$(git_cmpl diff --name-only --diff-filter=U 2>/dev/null || true)
  if [[ -n "${conflict_files}" ]]; then
    echo "Conflicting files:"
    echo "${conflict_files}" | sed 's/^/  - /'
    echo ""
  fi

  fail "Diverged. Resolve manually then run: git push ${ORIGIN_REMOTE} ${UPSTREAM_BRANCH}"
fi

# ─── case 3: local only (upstream behind local) ─────────────────────────────
if [[ "${UPSTREAM_AHEAD}" -eq 0 && "${LOCAL_AHEAD}" -gt 0 ]]; then
  info "Upstream is behind local. Pushing local to origin..."
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "[dry-run] Would push to origin"
    exit 0
  fi
  git_cmpl push "${ORIGIN_REMOTE}" "${UPSTREAM_BRANCH}"
  info "✓ Push complete."
  exit 0
fi