#!/usr/bin/env bash
# Local preview at http://127.0.0.1:4000/ (copies _posts/*/assets on each build)
set -euo pipefail
cd "$(dirname "$0")"
export PATH="${HOME}/.local/share/gem/ruby/3.4.0/bin:${PATH}"
exec ./scripts/jekyll-with-post-assets serve --config _config.yml,_config_local.yml "$@"
