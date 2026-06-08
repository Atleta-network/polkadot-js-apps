#!/usr/bin/env bash
set -Eeuo pipefail

release_tag="${RELEASE_TAG:?RELEASE_TAG is required}"
upstream_repo="${UPSTREAM_REPO:-polkadot-js/apps}"
target_branch="${TARGET_BRANCH:-atleta}"
sync_branch="${SYNC_BRANCH:-}"

safe_tag="$(printf "%s" "${release_tag}" | tr -cs 'A-Za-z0-9_.-' '-')"
if [ -z "${sync_branch}" ]; then
  sync_branch="sync/upstream-${safe_tag}"
fi

write_output() {
  local key="$1"
  local value="$2"

  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    printf "%s=%s\n" "${key}" "${value}" >> "${GITHUB_OUTPUT}"
  fi
}

git fetch --prune origin "${target_branch}"
git checkout -B "${sync_branch}" "origin/${target_branch}"

if git remote get-url upstream >/dev/null 2>&1; then
  git remote set-url upstream "https://github.com/${upstream_repo}.git"
else
  git remote add upstream "https://github.com/${upstream_repo}.git"
fi

git fetch --force --no-tags upstream "refs/tags/${release_tag}:refs/tags/${release_tag}"

write_output "sync_branch" "${sync_branch}"
write_output "release_tag" "${release_tag}"
write_output "upstream_repo" "${upstream_repo}"
write_output "target_branch" "${target_branch}"

if git merge-base --is-ancestor "${release_tag}" "origin/${target_branch}"; then
  echo "Upstream tag ${release_tag} is already contained in origin/${target_branch}."
  write_output "has_changes" "false"
  exit 0
fi

set +e
git merge --no-ff --no-commit "${release_tag}"
merge_status=$?
set -e

if [ "${merge_status}" -ne 0 ]; then
  echo "Upstream merge has conflicts. Resolve the files below in branch ${sync_branch}." >&2
  git diff --name-only --diff-filter=U >&2 || true
  git status --short >&2 || true
  write_output "has_changes" "false"
  exit "${merge_status}"
fi

if [ -f .git/MERGE_HEAD ]; then
  git commit -m "chore: sync upstream polkadot-js/apps ${release_tag}"
  write_output "has_changes" "true"
else
  echo "No merge commit was created for ${release_tag}; branch already matches target state."
  write_output "has_changes" "false"
fi

echo "Upstream ${upstream_repo}@${release_tag} merged into ${sync_branch}."
