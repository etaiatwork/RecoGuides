# TASK_LOG.md — RecoGuides Running Task Log
*Updated after every task. Source of truth for current state.*

---

## Current State
**Last updated**: 2026-03-22
**Site status**: ✅ Live at recoguides.com — PaperMod theme, full structure complete
**Build status**: ✅ Hugo 0.146.0 building cleanly on Netlify
**Theme mode**: ✅ Forced light mode (defaultTheme = "light", disableThemeToggle = true)
**Active verticals**: 1 (Productivity Tools)
**Articles published**: 6
**Affiliate status**: All PENDING — awaiting approval
**n8n**: ✅ Running at localhost:5678 — v2 workflow suite active (restarted clean 2026-03-21)
**AdSense**: ✅ Script in layouts/partials/extend_head.html (ca-pub-5124318262377242)
**Daily briefing**: ✅ N9 live — 7am ET cron + webhook trigger; missed-run watchdog (N11) active
**Article writing**: ✅ N8 unified writer — now supports briefing_items with scheduled publish dates
**Marketing**: ✅ N10 live — polls Netlify, queues Buffer posts
**Content calendar**: ✅ WF1 active (Monday 7am ET)
**Scheduled publishing**: ✅ Live — operator can append date to article selection (TODAY/TOMORROW/SAT/date)
**Schedule OFF**: ✅ Live — SCHEDULE OFF YYYY-MM-DD TO YYYY-MM-DD command blocks out dates
**Missed-run watchdog**: ✅ N11 live — auto-recovers missed N9 runs; BRIEF command for manual trigger

---

## Completed Tasks

### Phase 1: Architecture ✅
- ✅ 1A — config.toml updated (2026-03-13)
- ✅ 1B — data/affiliates.yaml created with 8 products including Wave (2026-03-13)
- ✅ 1C — affiliate-cta.html shortcode created and fixed (2026-03-13)
- ✅ 1D — affiliate-table.html shortcode created (2026-03-13)
- ✅ 1E — archetypes/default.md updated (2026-03-13)
- ✅ 1F — workspace files pushed to GitHub (2026-03-13)
- ✅ 1G — Netlify build fixed and confirmed live (2026-03-13)

### Phase 2: Site Redesign ✅
- ✅ Switched theme from hello-friend-ng to PaperMod (2026-03-16)
- ✅ Restructured content into /productivity-tools/ vertical hierarchy (2026-03-17)
- ✅ Created categories landing page at /categories/ (2026-03-16)
- ✅ Fixed homepage to show article feed with subcategory tags (2026-03-17)
- ✅ Fixed schema_json.html to prevent Hugo minifier errors (2026-03-17)
- ✅ Added Google Analytics G-JVSLQ905JV (2026-03-17)
- ✅ Removed dark mode toggle (2026-03-16)
- ✅ Added Contact page (2026-03-16)
- ✅ Fixed affiliate shortcode syntax across all articles (2026-03-16)

### Phase 3: Content — 6 Articles Live ✅
- ✅ 2A — ClickUp vs Asana 2026 (2026-03-13) — /productivity-tools/project-management/
- ✅ 2B — Best PM Tools for Freelancers 2026 (2026-03-14)
- ✅ 2C — Monday vs ClickUp Small Business 2026 (2026-03-15)
- ✅ 3A — Toggl vs Harvest vs Clockify 2026 (2026-03-15) — /productivity-tools/time-tracking/
- ✅ 3B — Best Time Tracking Tools for Freelancers 2026 (2026-03-15)
- ✅ 4A — FreshBooks vs Wave 2026 (2026-03-15) — /productivity-tools/invoicing/

### Infrastructure ✅
- ✅ n8n installed in Docker at ~/n8n-docker/ (2026-03-17)
- ✅ n8n accessible at localhost:5678 (2026-03-17)
- ✅ n8n API key stored in ~/n8n-docker/.env (2026-03-17)
- ✅ Claude Code installed at /home/elyrosenstock/.npm-global/bin/claude (2026-03-17)
- ✅ RecoGuides repo cloned permanently to ~/RecoGuides/ (2026-03-17)

### Phase N: n8n Workflow Suite ✅
- ✅ WF1 — Monday Content Research (2026-03-17): Tavily × 7 products, Gemini scoring, calendar push, Telegram delivery
- ✅ WF2 — Telegram Reply Handler (2026-03-17, updated 2026-03-19): handles OK, REPLACE, WRITE, SKIP, number selections
- ✅ N2/N3 — Duplicate detection, 3-slot calendar, dynamic publish dates (2026-03-17)
- ✅ N5/N6/N7 deleted — replaced by unified N8 Article Writer (2026-03-19)
- ✅ N8 — Unified Article Writer (2026-03-19): webhook trigger, all content types, correct paths/author/frontmatter
- ✅ N9 — Daily Morning Briefing (2026-03-19): 7am ET, Tavily AI/SMB search, Gemini headlines, Telegram numbered list
- ✅ N10 — Marketing Agent (2026-03-19): polls Netlify deploys, Gemini social posts, Buffer queue staggered

### Session 3: Strategy Update ✅
- ✅ MISSION.md updated — new strategy: AdSense primary, RecoGuides Team byline, SMB/AI focus, daily briefing flow (2026-03-19)
- ✅ OPERATIONS.md updated — new frontmatter schema (summary field, no categories), vendor-link shortcode, PaperMod rules (2026-03-19)
- ✅ workspace files synced: openclaw-docker/workspace → RecoGuides/workspace → GitHub (2026-03-19)
- ✅ Google AdSense added to layouts/partials/extend_head.html (ca-pub-5124318262377242) (2026-03-19)

---

## Active Tasks

### Session 4: Infrastructure Fixes + Scheduled Publishing ✅

- ✅ **S4-1** — GITHUB_TOKEN duplicate check — no duplicate found, credentials clean (2026-03-21)
- ✅ **S4-2** — n8n restarted clean — root cause of N9 Saturday miss: container crash between Fri/Sat (2026-03-21)
- ✅ **S4-3** — N9 re-activated — will fire Sunday March 22 at 7am ET (2026-03-21)
- ✅ **S4-4** — config.toml: added `defaultTheme = "light"` — site forced to light mode always (2026-03-21)
- ✅ **S4-5** — WF2 (Telegram Reply Handler): date suffix parsing added to article selection (2026-03-21)
  - "1, 3 TODAY" → publishes today; "2 TOMORROW"; "4 SAT"; "5 2026-03-28"
  - SCHEDULE OFF YYYY-MM-DD TO YYYY-MM-DD command added
- ✅ **S4-6** — N8 (Article Writer): briefing_items path added — uses publishDate per article (2026-03-21)
  - Future-dated articles tracked in workspace/schedule_state.json
  - Hugo date set to publishDate — articles held until then natively
- ✅ **S4-7** — N9 (Daily Morning Briefing): checks schedule_state.json for articles going live today (2026-03-21)
  - Checks calendar_state.json for upcoming blackout dates (warns 7 days in advance)
  - Updated reply instructions in briefing message

### Session 5: Missed-Run Watchdog (2026-03-22) ✅

- ✅ **S5-1** — N9 (Daily Morning Briefing): webhook trigger added at `/webhook/morning-briefing` (2026-03-22)
  - Cron trigger (7am ET) preserved; same code node runs for both triggers
  - New ID: `pk2Gvf0rWSCbNJvB`
- ✅ **S5-2** — N11 (Missed-Run Watchdog): new workflow — every 30 minutes (2026-03-22)
  - Looks up N9 by name via n8n API (survives re-deployments)
  - If N9 has NOT run today and time < 11am ET → triggers N9 via webhook
  - If N9 has NOT run today and time ≥ 11am ET → Telegram: "⚠️ Today's briefing was missed. Reply BRIEF to get today's headlines now."
  - ID: `kkstWmRQgTMsVlBv`
- ✅ **S5-3** — WF2 (Telegram Reply Handler): BRIEF command added (2026-03-22)
  - Reply `BRIEF` at any time → triggers N9 via `/webhook/morning-briefing`
  - New ID: `ue1BErcKQilsVi1h`
- ✅ **S5-4** — deploy_watchdog.py created at `~/n8n-docker/deploy_watchdog.py` (2026-03-22)

### Session 6: QC Workflow
*(Next priority)*

- [ ] **QC1** — Build post-publish QC checker workflow:
  - Verify article URL accessible (HTTP 200)
  - Check shortcodes rendered (no raw `{{<` text visible)
  - Verify AdSense script present in page source
  - Check word count reasonable (800+ words)
  - Send Telegram alert if any check fails / confirmation if all pass
  - Triggers after each Netlify deploy (coordinate with N10 Marketing Agent)

### Content Queue
*(Ongoing — written via N8 Article Writer based on daily briefing + calendar)*

#### Project Management
- [ ] **2D** — ClickUp Review 2026: Is It Worth It?
- [ ] **2E** — Asana Review 2026: Honest Pros and Cons
- [ ] **2F** — Best Project Management Tools for Solo Freelancers
- [ ] **2G** — Monday.com vs Asana: Which Wins for Small Teams?
- [ ] **2H** — Best Project Management Tools for Creative Agencies

#### Time Tracking
- [ ] **3C** — Toggl Review 2026: Still the Best?
- [ ] **3D** — Harvest Review 2026: Time Tracking + Invoicing in One
- [ ] **3E** — Clockify Review 2026: Is the Free Plan Enough?
- [ ] **3F** — How to Choose a Time Tracking Tool: Complete 2026 Guide

#### Invoicing
- [ ] **4B** — Best Invoicing Software for Freelancers in 2026
- [ ] **4C** — FreshBooks Review 2026: Worth the Price?
- [ ] **4D** — Wave Review 2026: Is Free Good Enough?

---

## Manual Tasks for Operator
- [ ] Apply for Impact.com affiliate account
- [ ] Apply for ShareASale affiliate account
- [ ] Apply for CJ Affiliate account
- [ ] Apply for Rakuten account
- [ ] Follow up on ClickUp PartnerStack application
- [ ] Apply for Asana affiliate on PartnerStack
- [ ] Apply for Monday.com affiliate on PartnerStack
- [ ] Regenerate n8n API key (exposed in conversation — go to n8n → Settings → API)
- [ ] Verify Google AdSense account approved and serving ads (ca-pub-5124318262377242)
- [ ] Set up Buffer profiles for LinkedIn and Twitter/X (needed for N10 Marketing Agent)

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
| FreshBooks | ShareASale/Direct | [ ] | [ ] | [ ] |
| Toggl Track | Direct | [ ] | [ ] | [ ] |
| Harvest | Direct | [ ] | [ ] | [ ] |
| Clockify | Direct | [ ] | [ ] | [ ] |
| Wave | Direct | [ ] | [ ] | [ ] |

---

## Blockers / Notes
- n8n API key was exposed in Claude conversation on 2026-03-17 — regenerate ASAP
- GitHub token in CREDENTIALS.local may expire — if 401 errors occur, generate new token at github.com
- Netlify token may expire — same protocol
- All affiliate URLs PENDING — vendor-link shortcodes render but link to websiteUrl until active
- Buffer profiles needed for N10 Marketing Agent — set up LinkedIn + Twitter/X profiles in Buffer, confirm BUFFER_API_KEY works
- N8 Article Writer webhook URL: http://localhost:5678/webhook/article-writer
