# AGENTS.md - Notes from the terminal

Instructions for AI coding agents working on this repository. Follow these rules unless the user explicitly overrides them.

## Project

- **What:** Personal dev/IT blog (home lab, networking, Docker, Linux war stories).
- **Stack:** Jekyll + GitHub Pages (`github-pages` gem).
- **Site name:** Notes from the terminal.
- **Production URL:** `https://slci.github.io/blog/` (`url` + `baseurl: /blog` in `_config.yml`).
- **Tone of content:** Practical walkthroughs - what broke, why, and the commands that fixed it. Not marketing, not LinkedIn-speak.

## Local preview

Prefer:

```bash
./serve.sh
# equivalent:
# bundle exec jekyll serve --config _config.yml,_config_local.yml
```

Open `http://127.0.0.1:4000/`.

`_config_local.yml` clears `baseurl` so `/` works. Plain `bundle exec jekyll serve` (production config only) serves only at `http://127.0.0.1:4000/blog/`; requests to `/` log `ERROR '/' not found` - that is expected, not a site bug.

Ruby gems: `bundle install` (path often `vendor/bundle`). On Ruby 3.4+, Gemfile may need explicit `erb`, `csv`, `logger`, `base64`, `bigdecimal`.

Do **not** commit `_site/` or `vendor/` (see `.gitignore`).

## Layout and site structure

| Path | Role |
|------|------|
| `_config.yml` | Production Jekyll config |
| `_config_local.yml` | Local overrides (empty baseurl) |
| `_layouts/` | `default`, `home`, `post`, `page` |
| `_posts/<slug>/YYYY-MM-DD-<slug>.md` | One directory per post (Jekyll still requires `DATE-title.md` filename) |
| `_posts/<slug>/assets/` | Post-only media (diagrams, images, sources) - **source of truth** |
| `assets/css/main.css` | Site styles (source of truth for visual system) |
| `assets/images/` | **Site-wide** assets only (favicons, shared chrome) |
| `scripts/copy_post_assets.rb` | Copies `_posts/*/assets/**` → `_site/assets/posts/<slug>/**` on each build |
| `scripts/jekyll-with-post-assets` | Runs Jekyll with that hook (use this, not bare `jekyll`) |
| `about.md`, `index.md` | Static pages |
| `serve.sh` | Local serve helper |

### Per-post layout (required)

```text
_posts/<slug>/
  YYYY-MM-DD-<slug>.md
  assets/
    diagram.svg
    diagram.excalidraw
    photo.png
```

- Subdirectories under `_posts/` are supported; they are **not** part of the public URL.
- Filename must still match `YYYY-MM-DD-title.md`.
- Prefer `slug` = short kebab-case id (e.g. `tailscale-docker-immich`).
- Jekyll does not publish non-post files under `_posts/` by default. The `github-pages` gem also disables `_plugins/`. Use **`./scripts/jekyll-with-post-assets`** (or `./serve.sh`) so `scripts/copy_post_assets.rb` registers a `post_write` hook and copies each post's `assets/` into the built site at **`/assets/posts/<slug>/`**.
- Reference post assets with Liquid + `relative_url` (public path, not the `_posts` path):

```markdown
![Alt text]({{ '/assets/posts/<slug>/diagram.svg' | relative_url }})
```

- Do **not** put post-specific media under `assets/images/` (that folder is for favicons and global UI).
- Prefer `./serve.sh` / `./scripts/jekyll-with-post-assets build` over bare `bundle exec jekyll …` so post assets are not missing.
- Deploy via `.github/workflows/pages.yml` (GitHub Actions) so production builds include the copy step. In repo Settings → Pages, set Source to **GitHub Actions**.

New posts use front matter:

```yaml
---
layout: post
title: "Title in sentence case (not Title Case For Every Word)"
date: YYYY-MM-DD
tags: [tag1, tag2]
excerpt: >-
  Short plain summary for the index and SEO.
---
```

Permalink pattern: `/:year/:month/:day/:title/` (from `_config.yml`; independent of the `_posts/` subdirectory).

---

## Writing rules (mandatory)

### Character ban: no em/en dashes

**Never use the Unicode em dash (U+2014) or en dash (U+2013).** Always use a normal ASCII hyphen-minus `-` (U+002D) instead.

To detect: search for characters that are not ASCII `-` but look like long dashes in copy-paste from Word/LLM output.

Also avoid double-hyphen used as a dash (` -- `). Prefer commas, periods, colons, or parentheses.

This applies to posts, UI copy, CSS comments, diagram labels, README, and commit messages written for this project.

### Sound human (use the humanizer skill)

When drafting or editing post prose, apply the **humanizer** skill (`humanizer` / Wikipedia "Signs of AI writing" patterns). Goals:

- Less LinkedIn / brochure tone; more first-person lab notes.
- Prefer simple copulas (`is` / `are` / `has`) over "serves as", "stands as", "boasts".
- Avoid AI vocabulary: pivotal, landscape, delve, showcase, underscore, vibrant, tapestry, testament, crucial (as filler), etc.
- Avoid rule-of-three padding, fake significance, "Let's dive in", "Here's what you need to know".
- Avoid bold-on-every-term and emoji headings.
- Vary sentence length; keep specific commands, paths, and errors.
- Do not invent facts, IPs, package versions, or outcomes not in the source material or user session.

### Post shape (default for technical stories)

Unless the user asks for another structure, prefer four chapters:

1. **Introduction** - goal, constraints, and context (e.g. why HTTP over Tailscale can still be reasonable).
2. **Problem** - what failed in the real world (symptoms).
3. **Troubleshooting** - how to diagnose; make the method **reusable**, not only a diary.
4. **Solution** - exact fix, verify live state, optional follow-ups.

Prefer concise posts. If asked to shorten, cut about **20%** without dropping facts the user cares about.

### Domain voice

- Home lab / IT: Tailscale, Docker, UFW, Immich, Linux, networking are in scope.
- Prefer copy-pasteable commands and real file paths.
- Call out gotchas (e.g. file on disk vs live `iptables`, IPv4 vs IPv6 rule files).

---

## Visual style

### Overall site

- **Light page:** white / near-white background, clean layout, readable measure (`--max` ~42rem).
- **Restraint:** color is fine; do not over-paint or add heavy decoration.
- System UI font for body; monospace for code.
- Tags and links use a modest blue accent; keep the chrome minimal.

### Code highlighting (Catppuccin)

| Markdown | Theme | Notes |
|----------|--------|--------|
| Fenced blocks ` ``` ... ``` ` | **Catppuccin Frappé** (dark terminal) | All fenced blocks, one-line or multi-line |
| Inline `` `code` `` | **Catppuccin Latte** (light chip) | Mauve text on light base |

**Critical Jekyll detail:** Inline code is emitted as  
`<code class="language-plaintext highlighter-rouge">...</code>`.  
Fenced blocks are wrapped in `<div class="highlighter-rouge">`.

Therefore:

- Dark Frappé styles must target **`div.highlighter-rouge`** (and `figure.highlight` / bare `pre` blocks), **not** bare `.highlighter-rouge`.
- Latte inline styles must target **`code.highlighter-rouge`** and `:not(pre) > code`.
- Rouge token colors live under `div.highlighter-rouge .highlight ...`.
- Fenced `pre code` inherits terminal colors; do not style it as a Latte chip.

Palette references:

- Frappé: https://terminalcolors.com/themes/catppuccin/frappe/
- Latte: https://terminalcolors.com/themes/catppuccin/latte/

CSS variables for both palettes live in `assets/css/main.css` (`--frappe-*`, `--latte-*`).

### Diagrams

- Prefer a **mild sketch** look: slight hand-drawn roughness, light hachure optional, **not** heavily deformed shapes.
- Shapes should stay close to rounded rectangles (readable, "ideal" geometry with a sketch filter).
- **Colors:** Catppuccin **Latte** (success green `#40a02b`, error red `#d20f39`, blue `#1e66f5`, yellow `#df8e1d`, text `#4c4f69`, page `#eff1f5`).
- Keep editable **Excalidraw** sources (`.excalidraw`) next to published `.svg` / `.png` when creating technical diagrams.
- Use the **excalidraw-diagram** skill when producing Excalidraw JSON; for blog embed, ship SVG (and optional PNG).
- No em dashes in diagram labels.

Example diagram assets for the Tailscale/Docker post (in-repo path):

- `_posts/tailscale-docker-immich/assets/tailscale-docker-docker-user-sketch.svg` (primary embed)
- `_posts/tailscale-docker-immich/assets/tailscale-docker-docker-user-sketch.excalidraw`
- `_posts/tailscale-docker-immich/assets/tailscale-docker-docker-user-sketch.png`

Published URL prefix: `/assets/posts/tailscale-docker-immich/`.

### Favicons

Source of truth: `assets/images/favicon-source.png`.

After the user updates the source, regenerate:

```bash
SRC=assets/images/favicon-source.png
for s in 16 32 48 64; do
  magick "$SRC" -filter Lanczos -resize ${s}x${s} assets/images/favicon-${s}.png
done
magick "$SRC" -filter Lanczos -resize 180x180 assets/images/apple-touch-icon.png
magick assets/images/favicon-16.png assets/images/favicon-32.png \
      assets/images/favicon-48.png assets/images/favicon-64.png favicon.ico
cp -f favicon.ico assets/images/favicon.ico
```

Bump `?v=N` on favicon `<link>` tags in `_layouts/default.html` so browsers pick up changes.

`favicon.ico` at repo root is served at site root (with local empty baseurl) or under `/blog/` in production.

---

## Skills and tools (use when relevant)

| Skill / tool | When |
|--------------|------|
| **humanizer** | Drafting or editing blog prose; strip AI writing tells |
| **excalidraw-diagram** | Architecture / flow diagrams as `.excalidraw` |
| ImageMagick (`magick`) | Favicons, SVG→PNG rasterization |
| Jekyll / `bundle exec` | Build and local serve |

Do not reintroduce removed machinery (e.g. `code-blocks.js` one-line classifier) unless the user asks. Fenced vs inline theming is CSS-only via Jekyll's markup.

---

## Technical content notes (session-derived)

When writing about Tailscale + Docker + UFW on this author's setup, remember proven facts from the lab:

- Tailscale CGNAT is `100.64.0.0/10`; ufw-docker often only allows RFC1918 in `DOCKER-USER`.
- LAN can work while Tailscale fails: classic symptom.
- Fix: `RETURN -s 100.64.0.0/10` in `/etc/ufw/after.rules`; IPv6 twin in `/etc/ufw/after6.rules` (never put IPv6 `/48` in the IPv4 rules file).
- Always verify the **live** chain (`iptables -L DOCKER-USER -n -v`), not only the file; `Firewall not enabled (skipping reload)` means rules never applied.
- Exit node needs forwarding + UFW route rules; that does **not** by itself open Docker published ports.
- Plain HTTP over Tailscale is encrypted on the WireGuard path between peers; still not a substitute for public HTTPS.

Do not invent hostnames or IPs; use placeholders (`100.x.x.x`, `192.168.x.x`) or values the user supplies.

---

## Git and delivery

- Do not force-push or amend published history unless asked.
- Do not commit secrets.
- Prefer small, focused commits when the user requests a commit.
- After style or post edits, a local `bundle exec jekyll build` (or serve) is enough to sanity-check; mention hard-refresh if CSS/favicon cache may stick.

---

## Checklist before finishing a change

1. No Unicode em dash (U+2014) or en dash (U+2013) in edited text/assets labels - only ASCII `-`.
2. Prose passed a humanizer pass if it is user-facing article text.
3. Fenced code dark (Frappé); inline code light (Latte); selectors use `div.highlighter-rouge` vs `code.highlighter-rouge`.
4. Diagrams: Latte colors, mild sketch, not excessively wobbly.
5. New posts: front matter, sensible tags, excerpt without hype.
6. Local serve instructions remain accurate if config scripts change.
