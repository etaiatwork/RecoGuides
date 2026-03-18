# TASK_LOG.md — RecoGuides Running Task Log
*Etai updates this after every task. This is the source of truth for current state.*

---

## Current State
**Last updated**: 2026-03-17
**Site status**: ✅ Live at recoguides.com — PaperMod theme, full structure complete
**Build status**: ✅ Hugo building cleanly on Netlify
**Active verticals**: 1 (Micro-SaaS Tools)
**Articles published**: 6 (3 project management, 2 time tracking, 1 invoicing)
**Affiliate status**: All PENDING — awaiting approval

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
  - Path: content/project-management/clickup-vs-asana-2026.md
  - Categories: [project-management], Tags: [clickup, asana, comparison, freelance, teams]

- ✅ **2B** — Write: "Best Project Management Tools for Freelancers in 2026"
  - Path: content/project-management/best-project-management-tools-freelancers-2026.md
  - Categories: [project-management, freelance]

- ✅ **2C** — Write: "Monday.com vs ClickUp: A Deep Dive for Small Business Owners"
  - Path: content/project-management/monday-vs-clickup-small-business-2026.md
  - Categories: [project-management, small-business]

- [ ] **2D** — Write: "ClickUp Review 2026: Is It Worth It?"
  - Path: content/project-management/clickup-review-2026.md
  - Categories: [project-management]

- [ ] **2E** — Write: "Asana Review 2026: Honest Pros and Cons"
  - Path: content/project-management/asana-review-2026.md
  - Categories: [project-management]

- [ ] **2F** — Write: "Best Project Management Tools for Solo Freelancers"
  - Path: content/project-management/best-pm-tools-solo-freelancers.md
  - Categories: [project-management, freelance]

- [ ] **2G** — Write: "Monday.com vs Asana: Which Wins for Small Teams?"
  - Path: content/project-management/monday-vs-asana-small-teams.md
  - Categories: [project-management, small-business]

- [ ] **2H** — Write: "Best Project Management Tools for Creative Agencies"
  - Path: content/project-management/best-pm-tools-creative-agencies.md
  - Categories: [project-management, freelance]

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
- ✅ **N1** — Install n8n in Docker at ~/n8n-docker/, port 5678, America/New_York, auto-restart, credentials from CREDENTIALS.local (2026-03-17)
- ✅ **N2** — Build Monday Content Research workflow: Tavily search (21 queries × 7 products) → Gemini scoring/ranking → CONTENT_CALENDAR.md → GitHub push → Telegram delivery with dated slots; Telegram Reply Handler polls every 2 min for OK/REPLACE (2026-03-17)
- ✅ **N3** — Add duplicate detection (Jaccard similarity + slug match against existing articles), fix 3-slot Sunday/Wednesday/Friday schedule with locked category mapping (PM/TT/Invoicing), fix dynamic publish dates in Telegram message (2026-03-17)

### Phase 4: Weekly Recurring Tasks
*(Begin after first 5 articles are published)*
- ✅ Set up Monday news search routine across all tracked products (completed via N1–N3 above)
- [ ] Research and pitch 1-2 new verticals to operator
- [ ] Maintain 2 evergreen articles per active vertical per week

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
| Toggl Track | Direct | [ t | [ ] | [ ] |
| Harvest | Direct | [ ] | [ ] | [ ] |
| Clockify | Direct | [ ] | [ ] | [ ] |

---

## Blockers / Notes
- GitHub token may expire — if GitHub API calls fail with 401, notify operator for new token
- Netlify token may expire — same protocol
- All affiliate URLs currently PENDING — shortcodes render but link to product homepages until active