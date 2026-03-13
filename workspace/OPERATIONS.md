# OPERATIONS.md — How Etai Works
*Technical standards and workflows. Read at the start of every session.*

---

## GitHub Workflow (Always follow this exactly)

### To read a file:
GET https://api.github.com/repos/etaiatwork/RecoGuides/contents/{path}
Headers: Authorization: token {{GITHUB_TOKEN}}

### To create or update a file:
1. GET the file first to retrieve its SHA (if it already exists)
2. Base64 encode your new content
3. PUT to GitHub API:
PUT https://api.github.com/repos/etaiatwork/RecoGuides/contents/{path}
Headers: Authorization: token {{GITHUB_TOKEN}}
Body: { "message": "commit message", "content": "{base64}", "sha": "{sha if updating}" }

### To trigger a Netlify deploy:
POST https://api.netlify.com/api/v1/sites/{{NETLIFY_SITE_ID}}/builds
Headers: Authorization: Bearer {{NETLIFY_TOKEN}}

---## Site File Structure

RecoGuides/
├── config.toml
├── archetypes/
│   └── default.md
├── content/
│   ├── about.md
│   ├── project-management/
│   ├── time-tracking/
│   └── invoicing/
├── data/
│   └── affiliates.yaml
├── layouts/
│   └── shortcodes/
│       ├── affiliate-cta.html
│       └── affiliate-table.html
├── themes/
│   └── hello-friend-ng/
└── workspace/
    ├── MISSION.md
    ├── OPERATIONS.md
    └── TASK_LOG.md

---

## Standard Article Frontmatter
Every article must use this exact frontmatter schema:

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

---

## Affiliate Shortcode Usage

### Single product CTA (use after each product section):
{{< affiliate-cta "clickup" >}}

### Comparison table (use near top of comparison articles):
{{< affiliate-table "clickup,asana,monday" >}}

Valid product slugs: clickup, asana, monday, freshbooks, toggl, harvest, clockify

---

## Taxonomy System
Hugo taxonomies in use:

| Taxonomy | Purpose | Example values |
|----------|---------|----------------|
| categories | Topic area | project-management, time-tracking, invoicing, freelance, small-business |
| tags | Specific keywords | clickup, asana, comparison, billing, productivity |
| verticals | Business vertical | micro-saas |

Rule: Every article must have at least 2 categories. More = better for cross-linking.

---

## Hugo Build Rules (Avoid These Known Issues)
- author in config.toml must be an array: author = ["Etai Ocarn"]
- Never use smart quotes in frontmatter — use straight quotes only
- draft: false must be set or article won't publish
- Date format must be: 2026-03-07T13:57:00Z

---

## Task Log Protocol
After completing ANY task, Etai must update TASK_LOG.md:
1. Mark completed items with ✅ and date
2. Update "Current State" section
3. Add any new tasks discovered
4. Note any blockers or errors encountered
5. Commit TASK_LOG.md to GitHub after every update
