# Notes from the terminal

Personal dev/IT blog, published with **GitHub Pages** (Jekyll).

## Local preview

```bash
cd /home/slci/git/blog
bundle install
./serve.sh
# or: bundle exec jekyll serve --config _config.yml,_config_local.yml
```

Open <http://127.0.0.1:4000/>.

Production uses `baseurl: /blog` (GitHub project pages). Local preview clears baseurl via `_config_local.yml` so `/` works and you do not get `ERROR '/' not found` when the browser hits the origin root.

If you run plain `bundle exec jekyll serve` (production config only), the site lives at <http://127.0.0.1:4000/blog/> - not at `/`.

## New post

One directory per post. Keep markdown and post-only media together:

```text
_posts/my-post-slug/
  YYYY-MM-DD-my-post-slug.md
  assets/
    diagram.svg
    photo.png
```

Front matter:

```yaml
---
layout: post
title: "Your title"
date: YYYY-MM-DD
tags: [tag1, tag2]
---
```

In the post body, link the **published** path (copied at build by `scripts/copy_post_assets.rb`):

```markdown
![Diagram]({{ '/assets/posts/my-post-slug/diagram.svg' | relative_url }})
```

Always build/serve via `./serve.sh` or `./scripts/jekyll-with-post-assets …` so those files land in `_site`. Bare `bundle exec jekyll build` skips them (`github-pages` disables `_plugins/`).

Site-wide favicons live in `assets/images/` (not under a post folder).

### GitHub Pages

`.github/workflows/pages.yml` builds with the post-assets hook and deploys. In repo **Settings → Pages**, set Source to **GitHub Actions**.

## GitHub Pages

1. Repo Settings → Pages → Source: **Deploy from a branch**
2. Branch: `main` / root (or `/docs` if you prefer)
3. Site URL will be `https://slci.github.io/blog/` if the repo is `slci/blog` (matches `baseurl` in `_config.yml`)

If you use a custom domain or rename the repo, update `url` and `baseurl` in `_config.yml`.
