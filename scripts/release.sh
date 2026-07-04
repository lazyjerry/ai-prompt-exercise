#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PROJECT_NAME=${PROJECT_NAME:-ai-prompt-exercise}
RELEASE_BRANCH=${RELEASE_BRANCH:-main}
BUILD_DIR=${BUILD_DIR:-public}

cd "$ROOT_DIR"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf '缺少必要指令：%s\n' "$1" >&2
    exit 1
  fi
}

require_command git
require_command npm

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "$RELEASE_BRANCH" ]; then
  printf '目前 branch 是 %s，發布 branch 應為 %s。\n' "$current_branch" "$RELEASE_BRANCH" >&2
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  printf '工作樹尚未乾淨，請先 commit 或 stash 後再發布。\n' >&2
  git status --short >&2
  exit 1
fi

if [ ! -d "$BUILD_DIR" ]; then
  printf '找不到發布目錄：%s\n' "$BUILD_DIR" >&2
  exit 1
fi

npm test

git fetch origin "$RELEASE_BRANCH"

set -- $(git rev-list --left-right --count "HEAD...origin/$RELEASE_BRANCH")
ahead=$1
behind=$2

if [ "$behind" -ne 0 ]; then
  printf '本機落後 origin/%s %s 個 commit，請先 pull/rebase 後再發布。\n' "$RELEASE_BRANCH" "$behind" >&2
  exit 1
fi

if [ "$ahead" -ne 0 ]; then
  git push origin "HEAD:$RELEASE_BRANCH"
fi

commit_hash=$(git rev-parse HEAD)
commit_message=$(git log -1 --pretty=%s)

npx wrangler pages deploy "$BUILD_DIR" \
  --project-name "$PROJECT_NAME" \
  --branch "$RELEASE_BRANCH" \
  --commit-hash "$commit_hash" \
  --commit-message "$commit_message"
