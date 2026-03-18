# SESSION_NOTES.md — RecoGuides
*Read this at the start of every session involving n8n or workflow automation.*

---

## Session: 2026-03-18 — Vendor-Link Shortcode + N4-N7 Workflows

### What Was Built

#### TASK 1: vendor-link shortcode
- Created `layouts/shortcodes/vendor-link.html`
- Looks up vendor slug in `site.Data.affiliates`
- active status → links to `affiliateUrl`
- pending status → links to `websiteUrl`
- slug not found → renders slug as plain text (no error)
- Tested by adding to all 6 existing articles

#### TASK 2: Updated all 6 articles
- Changed `author: "Etai Ocarn"` → `author: "RecoGuides Team"` in all frontmatter
- Added `{{< vendor-link "slug" >}}` on FIRST and LAST mention of each vendor in every article body
- Added Wave to `data/affiliates.yaml` (was missing, mentioned in freshbooks-vs-wave article)
- Added `wave` to `products:` list in freshbooks-vs-wave-freelancers-2026.md

#### TASK 3: Affiliate intake via Telegram (ADD AFFILIATE command)
- Integrated into WF2 (Telegram Reply Handler, id=4IPu8y21vF8fq6xS)
- Command format: `ADD AFFILIATE [company] [websiteUrl] [affiliateUrl or PENDING] [commission]`
- Example: `ADD AFFILIATE Notion https://notion.so PENDING 20%`
- Auto-generates slug (lowercase, hyphens), adds full YAML entry, pushes to GitHub, confirms via Telegram
- Handles duplicates gracefully (notifies if slug already exists)
- Sends usage hint if command format is invalid

#### TASK 4: N4-N7 Writing Trigger Workflows

**N4 (Breaking News — integrated into WF2 OK handler):**
- When operator sends OK to approve calendar AND a BREAKING slot exists:
  1. Writes breaking news article via Gemini (800-1000 words)
  2. Pushes to `content/productivity-tools/{category}/{slug}.md`
  3. Triggers Netlify deploy
  4. Sends Telegram confirmation with URL

**N5 (Sunday 8am ET — Project Management):** WF id=nGDPGYr3phHsEnkB
**N6 (Wednesday 8am ET — Time Tracking):** WF id=oJj2xfABVYz6LaJG
**N7 (Friday 8am ET — Invoicing):** WF id=G36vfrSk2rFIFMKy

All three follow the same pipeline:
1. Schedule trigger (Sunday/Wednesday/Friday 8am ET)
2. Read `workspace/calendar_state.json` from GitHub
3. Check `state.approved === true`
4. Find the matching category slot (EVERGREEN type, not already published)
5. Check `slot.published` — skip if already done this week
6. Write full article via Gemini (1,400-1,800 words, following all MISSION/OPERATIONS rules)
7. Push to GitHub at correct `content/productivity-tools/{category}/{slug}.md` path
8. Mark slot as `published: true` in `calendar_state.json`
9. Trigger Netlify deploy + poll until `state: ready` (up to 3 min)
10. Send Telegram: ✅ Article live + URL

**Skip behavior:** If calendar not approved, slot missing, or already published — sends ℹ️ Telegram note and halts.

**Article content rules enforced in prompt:**
- 1,400-1,800 words (800-1,000 for breaking news)
- Author: "RecoGuides Team"
- Full frontmatter with SEO fields
- `{{< vendor-link "slug" >}}` on first + last vendor mention
- `{{< affiliate-cta "slug" >}}` after each vendor section
- Never hardcode URLs
- Ends with Bottom Line / Final Verdict

---

## Session: 2026-03-17 — n8n Automation Build (N1–N3)

### What Was Built

**Pipeline flow (Workflow 1 — Monday Content Research):**
1. Every Monday 8am ET — Schedule trigger
2. Tavily API: 7 products × 3 query types = 21 searches, `days: 7`
3. Fetch Existing Articles — GitHub Git Tree API, lists all `.md` under `content/productivity-tools/`
4. Score with Gemini — `gemini-2.0-flash`, 6 suggestions with dedup (Jaccard 0.45 + slug match)
5. Generate & Push Calendar — `CONTENT_CALENDAR.md` + `calendar_state.json` → GitHub `workspace/`
6. Format & Send Telegram — dated slots format

**Pipeline flow (Workflow 2 — Telegram Reply Handler):**
- Runs every 2 minutes
- Polls `getUpdates` with persistent `lastUpdateId` via `$getWorkflowStaticData`
- `OK` → approves calendar + triggers N4 (breaking news) if present
- `REPLACE [slot#] [new title]` → swaps title, regenerates calendar, resends
- `ADD AFFILIATE ...` → adds to affiliates.yaml (NEW in 2026-03-18 session)

---

## Current n8n Workflow IDs

| Workflow | Name | ID | Status |
|----------|------|----|--------|
| WF1 | Monday Content Research | `9roSxKaRZZGYpnEn` | ✅ Active |
| WF2 | Telegram Reply Handler | `4IPu8y21vF8fq6xS` | ✅ Active |
| N5 | Sunday PM Article Writer | `nGDPGYr3phHsEnkB` | ✅ Active |
| N6 | Wednesday TT Article Writer | `oJj2xfABVYz6LaJG` | ✅ Active |
| N7 | Friday Invoicing Article Writer | `G36vfrSk2rFIFMKy` | ✅ Active |

**n8n URL:** http://localhost:5678
**Deploy script:** `~/n8n-docker/update_workflow.py`

---

## Known Issues

1. **GITHUB_TOKEN in n8n-docker/.env is invalid** — Use CREDENTIALS.local token (`ghp_QMeTSf...`). The n8n container loads `.env` first. Fix: remove invalid token line from `.env`, recreate container.

2. **content/productivity-tools/ path** — All articles are under `content/productivity-tools/project-management/`, `time-tracking/`, `invoicing/`. WF1 dedup node filters for this path. Confirmed correct.

3. **Netlify deploy rule** — During Claude Code sessions: batch all changes, trigger ONE deploy at end. Do not trigger per-file. Production workflows (N4-N7) may trigger deploys independently as part of their publish pipeline.

4. **Gemini 429 rate limiting** — Free tier quota exhausted during rapid test runs. Not an issue in production (runs once weekly). Falls back to hardcoded suggestions.

5. **WF1_ID hardcoded in update_workflow.py** — Every deploy creates a new workflow with a new ID. Current IDs are in the registry above.

---

## Credentials Reference

All credentials live in **`~/openclaw-docker/workspace/CREDENTIALS.local`**.
Python loading pattern (first-occurrence-wins):

```python
env = {}
for path in ['~/openclaw-docker/workspace/CREDENTIALS.local', '~/n8n-docker/.env']:
    with open(os.path.expanduser(path)) as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                k, v = line.split('=', 1)
                if k.strip() not in env:
                    env[k.strip()] = v.strip()
```

Keys: `GITHUB_TOKEN`, `NETLIFY_TOKEN`, `NETLIFY_SITE_ID`, `TAVILY_API_KEY`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`, `GEMINI_API_KEY`, `N8N_API_KEY`

---

## What to Do Next Session

1. **Test the full pipeline** — Wait for next Monday 8am trigger (or manually execute WF1), send OK, verify N5 fires Sunday
2. **Verify vendor-link renders correctly** — Check recoguides.com article pages for linked vendor names
3. **Apply for affiliate networks** — Impact.com, ShareASale, CJ Affiliate, Rakuten (Task 5C)
4. **Write next content batch** — 2D, 2E, 3C, 3D, 3E, 4B, 4C from queue
5. **Update CREDENTIALS.local** — When new affiliate codes arrive, use ADD AFFILIATE command or update affiliates.yaml directly
