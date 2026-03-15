# OPERATIONS.md — How Etai Works
*Technical standards and workflows. Read at the start of every session.*

---

## GitHub Workflow (Always follow this exactly)

### To read a file:
```
GET https://api.github.com/repos/etaiatwork/RecoGuides/contents/{path}
Headers: Authorization: token {GITHUB_TOKEN}
```

### To create or update a file:
1. GET the file first to retrieve its SHA (if it already exists)
2. Base64 encode your new content
3. PUT to GitHub API:
```
PUT https://api.github.com/repos/etaiatwork/RecoGuides/contents/{path}
Headers: Authorization: token {GITHUB_TOKEN}
Body: { "message": "commit message", "content": "{base64}", "sha": "{sha if updating}" }
```

### To trigger a Netlify deploy:
```
POST https://api.netlify.com/api/v1/sites/{NETLIFY_SITE_ID}/builds
Headers: Authorization: Bearer {NETLIFY_TOKEN}
```

### To check deploy status:
```
GET https://api.netlify.com/api/v1/sites/{NETLIFY_SITE_ID}/deploys?per_page=1
Headers: Authorization: Bearer {NETLIFY_TOKEN}
```
Look for "state": "ready" = success. "state": "error" = failed.

---

## Site File Structure

```
RecoGuides/
├── config.toml                          # Site config, taxonomies, menu
├── archetypes/
│   └── default.md                       # Frontmatter template
├── content/
│   ├── about.md
│   ├── project-management/              # Vertical 1 articles
│   ├── time-tracking/                   # Vertical 1 articles
│   └── invoicing/                       # Vertical 1 articles
├── data/
│   └── affiliates.yaml                  # Central affiliate database
├── layouts/
│   └── shortcodes/
│       ├── affiliate-cta.html           # Single product CTA
│       └── affiliate-table.html         # Multi-product comparison table
├── themes/
│   └── hello-friend-ng/                 # Git submodule
└── workspace/                           # Etai memory (not deployed)
    ├── MISSION.md
    ├── OPERATIONS.md
    ├── TASK_LOG.md
    └── CREDENTIALS.local                # Never push this file
```

---

## Adding a New Vertical
When operator approves a new vertical:
1. Create content/{vertical-slug}/ directory by adding a placeholder _index.md
2. Add affiliate products to data/affiliates.yaml
3. Add menu item to config.toml if it should appear in nav
4. Begin writing articles with correct verticals: [{vertical-slug}] in frontmatter
No other config changes needed — Hugo handles the rest automatically.

---

## Standard Article Frontmatter
Every article must use this exact schema:

```yaml
---
title: ""
date: YYYY-MM-DDTHH:MM:SSZ
draft: false
author: "Etai Ocarn"
description: ""
featured_image: ""
categories: []
tags: []
verticals: []
products: []
affiliate_disclosure: "This guide contains affiliate links. We earn a commission when you sign up through our links at no extra cost to you."
seo:
  metaTitle: ""
  metaDescription: ""
  canonicalUrl: ""
---
```

---

## Affiliate Shortcode Usage

### Single product CTA:
```
{{</* affiliate-cta "clickup" */>}}
```

### Comparison table:
```
{{</* affiliate-table "clickup,asana,monday" */>}}
```

### Valid product slugs (Vertical 1):
`clickup`, `asana`, `monday`, `freshbooks`, `toggl`, `harvest`, `clockify`

---

## Taxonomy System

| Taxonomy | Purpose | Example values |
|----------|---------|----------------|
| categories | Topic area | project-management, time-tracking, invoicing, freelance, small-business |
| tags | Specific keywords | clickup, asana, comparison, billing, productivity |
| verticals | Business vertical | micro-saas |

**Rule**: Every article must have at least 2 categories.

---

## Affiliate Data File Structure
Each product in data/affiliates.yaml follows this schema:

```yaml
- slug: productname
  name: Product Name
  status: pending OR active
  affiliateUrl: "URL or PENDING_AFFILIATE_URL"
  websiteUrl: "https://product.com"
  logoPath: "/images/affiliates/product-logo.png"
  shortDescription: "One line description"
  commission: "Rate or PENDING"
  categories: [category1, category2]
  verticals: [vertical-slug]
  pros:
    - Pro 1
    - Pro 2
    - Pro 3
  cons:
    - Con 1
    - Con 2
```

When affiliate codes arrive: update status to "active" and affiliateUrl to real URL. All articles update automatically.

---

## Vertical Pitch Document Format
When pitching a new vertical to operator, use this format:

```
# Vertical Pitch: [Niche Name]

## Opportunity Summary
[2-3 sentences on why this niche is worth pursuing]

## Top 5 Target Keywords
| Keyword | Est. Monthly Searches | Competition |
|---------|----------------------|-------------|
| ...     | ...                  | ...         |

## Top Affiliate Programs
| Program | Commission | Network | Notes |
|---------|------------|---------|-------|
| ...     | ...        | ...     | ...   |

## Revenue Estimate
[At target conversion rate, estimated monthly revenue]

## Proposed First 10 Articles
1. ...
2. ...
[etc.]

## Verdict: GO / NO-GO
[Reasoning]
```

---

## Hugo Build Rules (Known Issues — Avoid These)
- `author` in config.toml must be array: `author = ["Etai Ocarn"]`
- Never use smart quotes in frontmatter — straight quotes only
- `draft: false` must be set explicitly
- Date format: `2026-03-07T13:57:00Z`
- Shortcodes use range loops for data lookup — never bracket notation
- Theme loads via git submodule — netlify.toml must include: `git submodule update --init --recursive &&` before hugo command

---

## Task Log Protocol
After completing ANY task, update workspace/TASK_LOG.md:
1. Mark completed items ✅ with date
2. Update "Current State" section
3. Add newly discovered tasks
4. Note blockers or errors
5. Commit TASK_LOG.md to GitHub after every update

---

## Weekly News Search Protocol (Every Monday)
Search for recent announcements from these products:
ClickUp, Asana, Monday.com, FreshBooks, Toggl, Harvest, Clockify
Plus any products in newly added verticals.

Search queries to run:
- "[Product name] new feature [current month year]"
- "[Product name] update [current month year]"
- "[Product name] pricing change [current year]"

If significant news found: write timely article first before evergreen content.
Format: "[Product] Just Released [Feature]: Here's What It Means for Freelancers"