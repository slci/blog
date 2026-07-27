#!/usr/bin/env bash
# Copy _posts/*/assets into _site/assets/posts/ (standalone, no Jekyll required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:-"$ROOT/_site"}"
export RUBYLIB="${ROOT}/scripts${RUBYLIB:+:$RUBYLIB}"
ruby -I"$ROOT/scripts" -r copy_post_assets -e "CopyPostAssets.call(ARGV[0], ARGV[1])" "$ROOT" "$DEST"
