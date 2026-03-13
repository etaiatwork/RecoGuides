# TASK_LOG.md — RecoGuides Running Task Log
*Etai updates this after every task. This is the source of truth for what has been done and what comes next.*

---

## Current State
Last updated: 2026-03-13
Site status: Live at recoguides.com — basic Hugo structure in place
Affiliate status: All PENDING — awaiting approval for ClickUp, Asana, Monday.com, FreshBooks, Toggl, Harvest, Clockify
Build status: Hugo build on Netlify was previously failing (exit code 2) due to author field format — now fixed

---

## Completed Tasks
*(Etai fills this in as tasks are done)*

---

## Active Tasks — Do These In Order

### PHASE 1: Architecture Setup

- [ ] 1A — Update config.toml:
  - Change title to: "RecoGuides - Expert Tool Comparisons for Freelancers & Teams"
  - Change homeSubtitle to: "Honest, data-driven comparisons to help you choose the right tools"
  - Change description to: "RecoGuides delivers independent, research-backed comparisons across tools for freelancers, small businesses, and remote teams."
  - Add taxonomy: vertical = "verticals"
  - Confirm menu order: Home, Project Management, Time Tracking, Invoicing, About
  - Confirm author = ["Etai Ocarn"] is array format

- [ ] 1B — Create data/affiliates.yaml with placeholder entries for: clickup, asana, monday, freshbooks, toggl, harvest, clockify. All status = "pending". Include: slug, name, status, affiliateUrl, websiteUrl, logoPath, shortDescription, commission, categories, verticals, pros, cons.

- [ ] 1C — Create layouts/shortcodes/affiliate-cta.html
- [ ] 1D — Create layouts/shortcodes/affiliate-table.html

- [ ] 1E — Update archetypes/default.md with standard frontmatter schema

- [ ] 1F — Commit all Phase 1 changes with message: "Architecture: affiliate data layer, shortcodes, updated config"

- [ ] 1G — Trigger Netlify deploy and confirm build succeeds

---

### PHASE 2: Content — Project Management Vertical

- [ ] 2A — Write and publish: "ClickUp vs Asana: Which Project Management Tool Is Right for You in 2026?"
  - Path: content/project-management/clickup-vs-asana-2026.md
  - Categories: [project-management], Tags: [clickup, asana, comparison, freelance], Verticals: [micro-saas]

- [ ] 2B — Write and publish: "Best Project Management Tools for Freelancers in 2026"
  - Path: content/project-management/best-project-management-tools-freelancers-2026.md
  - Categories: [project-management, freelance], Tags: [clickup, asana, monday, productivity], Verticals: [micro-saas]

- [ ] 2C — Write and publish: "Monday.com vs ClickUp: A Deep Dive for Small Business Owners"
  - Path: content/project-management/monday-vs-clickup-small-business-2026.md
  - Categories: [project-management, small-business], Tags: [monday, clickup, comparison], Verticals: [micro-saas]

- [ ] 2D — Commit all Phase 2 articles and trigger deploy

---

### PHASE 3: Content — Time Tracking Vertical
*(Begin after Phase 2 is complete)*

- [ ] 3A — Write and publish: "Toggl vs Harvest vs Clockify: Best Time Tracking Tool in 2026"
- [ ] 3B — Write and publish: "Best Time Tracking Tools for Freelancers Who Bill Hourly"
- [ ] 3C — Write and publish: "How to Choose a Time Tracking Tool: The Complete 2026 Guide"
- [ ] 3D — Commit and deploy

---

### PHASE 4: Content — Invoicing Vertical
*(Begin after Phase 3 is complete)*

- [ ] 4A — Write and publish: "FreshBooks vs Wave: Best Free Invoicing Tool for Freelancers"
- [ ] 4B — Write and publish: "Best Invoicing Software for Freelancers in 2026"
- [ ] 4C — Commit and deploy

---

### PHASE 5: Ongoing — SEO Velocity
*(25–30 articles per month target)*
- [ ] Identify next 10 article topics across all three verticals
- [ ] Write and publish in batches of 3–5
- [ ] Update TASK_LOG after each batch

---

## Blockers / Notes
*(Etai documents any errors, failed deploys, or issues here)*

---

## Affiliate Code Tracker
*(Update when codes arrive)*

| Product | Applied | Approved | Code Added to affiliates.yaml |
|---------|---------|----------|-------------------------------|
| ClickUp | [ ] | [ ] | [ ] |
| Asana | [ ] | [ ] | [ ] |
| Monday.com | [ ] | [ ] | [ ] |
| FreshBooks | [ ] | [ ] | [ ] |
| Toggl Track | [ ] | [ ] | [ ] |
| Harvest | [ ] | [ ] | [ ] |
| Clockify | [ ] | [ ] | [ ] |
