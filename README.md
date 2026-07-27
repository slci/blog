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

Create a file under `_posts/`:

```text
_posts/YYYY-MM-DD-short-title.md
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

## GitHub Pages

1. Repo Settings → Pages → Source: **Deploy from a branch**
2. Branch: `main` / root (or `/docs` if you prefer)
3. Site URL will be `https://slci.github.io/blog/` if the repo is `slci/blog` (matches `baseurl` in `_config.yml`)

If you use a custom domain or rename the repo, update `url` and `baseurl` in `_config.yml`.
