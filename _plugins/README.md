# Plugins

The `github-pages` gem forces a random `plugins_dir` and ignores this folder (local and on github.com).

Post assets are published via `scripts/copy_post_assets.rb`, loaded by `scripts/jekyll-with-post-assets` before Jekyll runs.
