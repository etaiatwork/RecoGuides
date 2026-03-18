# TASK_LOG.md — RecoGuides Running Task Log
*Etai updates this after every task. This is the source of truth for current state.*

---

## Current State
**Last updated**: 2026-03-18
**Site status**: ✅ Live at recoguides.com — PaperMod theme, full structure complete
**Build status**: ✅ Hugo building cleanly on Netlify
**Active verticals**: 1 (Micro-SaaS Tools)
**Articles published**: 6 (3 project management, 2 time tracking, 1 invoicing)
**Affiliate status**: All PENDING — awaiting approval
**Author byline**: Changed to "RecoGuides Team" across all 6 articles (2026-03-18)

---

## Completed Tasks

### Phase 1: Architecture ✅
- ✅ 1A — config.toml updated with new title, description, verticals taxonomy (2026-03-13)
- ✅ 1B — data/affiliates.yaml created with 7 placeholder products (2026-03-13)
- ✅ 1C — layouts/shortcodes/affiliate-cta.html created and fixed (2026-03-13)
- ✅ 1D — layouts/shortcodes/affiliate-table.html created and fixed (2026-03-13)
- ✅ 1E — archetypes/default.md updated with standard frontmatter (2026-03-13)
- ✅ 1F — workspace files (MISSION, OPERATIONS, TASK_LOG) pushed to GitHub (2026-03-13)
- ✅ 1G — Netlify build fixed (submodule init + shortcode syntax) and confirmed live (2026-03-13)

---

## Active Tasks

### Phase 2: Content — Micro-SaaS Vertical

#### Project Management Sub-vertical
- ✅ **2A** — Write: "ClickUp vs Asana: Which Project Management Tool Is Right for You in 2026?"
  - Path: content/productivity-tools/project-management/clickup-vs-asana-2026.md

- ✅ **2B** — Write: "Best Project Management Tools for Freelancers in 2026"
  - Path: content/productivity-tools/project-management/best-project-management-tools-freelancers-2026.md

- ✅ **2C** — Write: "Monday.com vs ClickUp: A Deep Dive for Small Business Owners"
  - Path: content/productivity-tools/project-management/monday-vs-clickup-small-business-2026.md

- [ ] **2D** — Write: "ClickUp Review 2026: Is It Worth It?"
- [ ] **2E** — Write: "Asana Review 2026: Honest Pros and Cons"
- [ ] **2F** — Write: "Best Project Management Tools for Solo Freelancers"
- [ ] **2G** — Write: "Monday.com vs Asana: Which Wins for Small Teams?"
- [ ] **2H** — Write: "Best Project Management Tools for Creative Agencies"

#### Time Tracking Sub-vertical
- ✅ **3A** — Write: "Toggl vs Harvest vs Clockify: Best Time Tracking Tool in 2026"
- ✅ **3B** — Write: "Best Time Tracking Tools for Freelancers Who Bill Hourly"
- [ ] **3C** — Write: "Toggl Review 2026: Still the Best?"
- [ ] **3D** — Write: "Harvest Review 2026: Time Tracking + Invoicing in One"
- [ ] **3E** — Write: "Clockify Review 2026: Is the Free Plan Enough?"
- [ ] **3F** — Write: "How to Choose a Time Tracking Tool: The Complete 2026 Guide"

#### Invoicing Sub-vertical
- ✅ **4A** — Write: "FreshBooks vs Wave: Best Free Invoicing Tool for Freelancers"
- [ ] **4B** — Write: "Best Invoicing Software for Freelancers in 2026"
- [ ] **4C** — Write: "FreshBooks Review 2026: Worth the Price?"

---

### Phase 3: Site Improvements
- ✅ **5A** — Fix homepage to display article listings instead of blank page
- ✅ **5B** — Fix logo/site name in top left to display "RecoGuides" correctly
- [ ] **5C** — Apply for affiliate accounts on Impact.com, ShareASale, CJ Affiliate, Rakuten

---

### Phase N: n8n Automation
- ✅ **N1** — Install n8n in Docker at ~/n8n-docker/, port 5678, America/New_York, auto-restart (2026-03-17)
- ✅ **N2** — Build Monday Content Research workflow: Tavily → Gemini → CONTENT_CALENDAR.md → GitHub → Telegram (2026-03-17)
- ✅ **N3** — Add duplicate detection, fix 3-slot schedule, fix dynamic publish dates (2026-03-17)
- ✅ **N4** — Breaking news writer: integrated into WF2 OK handler — when calendar is approved and a BREAKING slot exists, immediately writes article via Gemini, pushes to GitHub, triggers Netlify, sends Telegram confirmation (2026-03-18)
- ✅ **N5** — Sunday 8am ET: Project Management article writer — reads approved calendar, writes via Gemini, pushes to GitHub, deploys to Netlify, sends Telegram confirmation (2026-03-18) | WF ID: nGDPGYr3phHsEnkB
- ✅ **N6** — Wednesday 8am ET: Time Tracking article writer — same pipeline as N5 (2026-03-18) | WF ID: oJj2xfABVYz6LaJG
- ✅ **N7** — Friday 8am ET: Invoicing article writer — same pipeline as N5 (2026-03-18) | WF ID: G36vfrSk2rFIFMKy

### Phase V: Vendor-Link Shortcode
- ✅ **V1** — Created layouts/shortcodes/vendor-link.html: looks up slug in affiliates.yaml, links to affiliateUrl (active) or websiteUrl (pending), renders text-only if slug not found (2026-03-18)
- ✅ **V2** — Updated all 6 articles: changed author to "RecoGuides Team", added vendor-link shortcodes on first and last vendor mention in every article body (2026-03-18)
- ✅ **V3** — Added Wave to affiliates.yaml (was mentioned in freshbooks-vs-wave article but missing from data file) (2026-03-18)

### Phase A: Affiliate Intake
- ✅ **A1** — ADD AFFILIATE Telegram command integrated into WF2: operator sends "ADD AFFILIATE [company] [websiteUrl] [affiliateUrl or PENDING] [commission]" → auto-adds to affiliates.yaml → pushes to GitHub → Telegram confirmation (2026-03-18)

### Phase 4: Weekly Recurring Tasks
*(Begin after first 5 articles are published)*
- ✅ Set up Monday news search routine across all tracked products (N1–N3)
- ✅ Set up article writing triggers for Sunday/Wednesday/Friday (N5-N7)
- [ ] Research and pitch 1-2 new verticals to operator
- [ ] Maintain 2 evergreen articles per active vertical per week

---

## n8n Workflow Registry

| ID | Name | Trigger | Status |
|----|------|---------|--------|
| 9roSxKaRZZGYpnEn | Monday Content Research | Every Monday 8am ET | ✅ Active |
| 4IPu8y21vF8fq6xS | Telegram Reply Handler | Every 2 minutes | ✅ Active |
| nGDPGYr3phHsEnkB | N5: Sunday PM Article Writer | Sunday 8am ET | ✅ Active |
| oJj2xfABVYz6LaJG | N6: Wednesday TT Article Writer | Wednesday 8am ET | ✅ Active |
| G36vfrSk2rFIFMKy | N7: Friday Invoicing Article Writer | Friday 8am ET | ✅ Active |

---

## Vertical Expansion Pipeline
*(Etai researches and pitches — operator approves before any build)*

| Vertical | Status | Pitch Date | Decision |
|----------|--------|------------|----------|
| PC Hardware | Not started | — | — |
| Web Hosting | Not started | — | — |
| Travel/Hotels | Not started | — | — |
| Finance/Credit Cards | Not started | — | — |

---

## Affiliate Code Tracker

| Product | Network | Applied | Approved | Code Added |
|---------|---------|---------|----------|------------|
| ClickUp | PartnerStack | ✅ | [ ] | [ ] |
| Asana | PartnerStack | [ ] | [ ] | [ ] |
| Monday.com | PartnerStack | [ ] | [ ] | [ ] |
| FreshBooks | ShareASale | [ ] | [ ] | [ ] |
| Toggl Track | Direct | [ ] | [ ] | [ ] |
| Harvest | Direct | [ ] | [ ] | [ ] |
| Clockify | Direct | [ ] | [ ] | [ ] |
| Wave | Direct | [ ] | [ ] | [ ] |

---

## Blockers / Notes
- GitHub token may expire — if GitHub API calls fail with 401, notify operator for new token
- Netlify token may expire — same protocol
- All affiliate URLs currently PENDING — shortcodes render but link to product homepages until active
- GITHUB_TOKEN in n8n-docker/.env is invalid (ghp_Hs8W7...) — use CREDENTIALS.local token (ghp_QMeT...) for all GitHub operations
- Netlify deploy rule: batch all session changes, trigger ONE deploy at end of session only
