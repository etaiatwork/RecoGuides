# SESSION_NOTES.md — RecoGuides
*Read this at the start of every session involving n8n or workflow automation.*

---

## Session: 2026-03-17 — n8n Foundation (WF1, WF2, N2/N3)

### What Was Built

Monday Content Research pipeline (WF1) + Telegram Reply Handler (WF2).

**WF1 flow:** Every Monday 8am ET → Tavily (7 products × 3 queries = 21 searches) → Fetch Existing Articles (GitHub tree API, `content/productivity-tools/`) → Gemini scoring + Jaccard dedup → calendar_state.json + CONTENT_CALENDAR.md pushed to GitHub → Telegram HTML message.

**WF2 flow:** Polls every 2 minutes → handles `OK` (approve calendar) and `REPLACE [slot#] [title]` (swap + regenerate calendar + resend).

**Workflow IDs at time of build:**
- WF1 Monday Content Research: `9roSxKaRZZGYpnEn` (still active)
- WF2 Telegram Reply Handler: `4IPu8y21vF8fq6xS` (replaced in Session 3)

**Also deployed in 2026-03-17 (then deleted):**
- N5: Sunday PM Article Writer
- N6: Wednesday TT Article Writer
- N7: Friday Invoicing Article Writer

**Known issue from Session 2:** GITHUB_TOKEN duplicate in CREDENTIALS.local. Line 1 has the valid token. The Python deploy scripts use first-occurrence-wins to get the correct token. Docker's env_file uses last-write-wins, so n8n container may use wrong token. Fix: remove duplicate line from CREDENTIALS.local.

---

## Session: 2026-03-19 — n8n Workflow Suite v2 + Strategy Update

### What Changed (Strategy)

MISSION.md and OPERATIONS.md updated with new strategy:
- **Author byline**: Changed from "Etai Ocarn" → "RecoGuides Team" on all articles
- **Primary revenue**: Google AdSense (not just affiliate)
- **Content model**: Daily briefing-driven (7am ET → operator selects → write → batch deploy)
- **Content paths**: `content/productivity-tools/{subcategory}/{slug}.md` (confirmed correct)
- **Frontmatter**: Added required `summary` field; removed `categories` field; added `vendor-link` shortcode usage
- **Theme**: Confirmed PaperMod (not hello-friend-ng)

### What Was Built

**deploy_v2.py** — `~/n8n-docker/deploy_v2.py`

Deploys all v2 workflows in one script. Run: `cd ~/n8n-docker && python3 deploy_v2.py`

#### WF2 — Telegram Reply Handler (updated, id: BitiIHgtAwP1pAPN)
Now handles all commands:
- `OK` — approve weekly content calendar
- `REPLACE [slot#] [title]` — swap calendar slot
- `WRITE [slot#]` — trigger article writer for specific slot
- `WRITE ALL` — write all pending calendar slots
- `WRITE BREAKING` — write all breaking news slots
- `SKIP` — cancel today's morning briefing
- `1 3 5` (numbers) — select articles from morning briefing

#### N8 — Unified Article Writer (id: RvnAoHhWRyFx10xu)
- **Trigger**: Webhook POST to `http://localhost:5678/webhook/article-writer`
- **Input**: `{ "slot": 1 }` | `{ "slots": [1,2] }` | `{ "write_all": true }` | `{ "type": "breaking" }`
- **Flow**: Read calendar_state.json → generate article with Gemini → pre-publish checklist (affiliates.yaml) → push to `content/productivity-tools/{subcategory}/{slug}.md` → update calendar state → Telegram confirmation
- **Author**: "RecoGuides Team"
- **Frontmatter**: Includes `summary` field, no `categories` field, `verticals: ["productivity-tools"]`
- **Shortcodes**: vendor-link on first/last product mention, affiliate-cta after sections, tweet embeds for breaking/digest
- **Content types**: BREAKING (800-1000w), EVERGREEN (1500-1800w), DIGEST (800-1000w)

#### N9 — Daily Morning Briefing (id: gjo7ZtOLPv3fdulK)
- **Schedule**: Every day 7am ET (`0 7 * * *`)
- **Flow**: Tavily searches (9 queries, AI/SMB news, days:1) → Gemini compiles 8-10 headlines → save briefing_state.json to GitHub → send Telegram numbered list
- **State file**: `workspace/briefing_state.json`
- **Telegram format**: Breaking News section + Evergreen/Trending section, numbered sequentially
- **Replies**: Numbers (e.g. `1 3 5`) → saved to briefing_state.json → `WRITE ALL` to draft selected articles
- **SKIP**: Cancels the day — marks briefing_state.json as skipped

#### N10 — Marketing Agent (id: G0yFabAVwCIANg4K)
- **Schedule**: Every 5 minutes (`*/5 * * * *`)
- **Flow**: Check latest Netlify deploy (state: "ready") → compare to last processed deploy ID (static data) → if new: get changed content/ files from recent commits → Gemini drafts LinkedIn + Twitter/X posts per article → Buffer API queues posts staggered (9am ET + 2h per article) → Telegram confirmation
- **Buffer API**: `POST https://api.bufferapp.com/1/updates/create.json` with `access_token=BUFFER_API_KEY`, `profile_ids[]`, `text`, `scheduled_at`
- **State**: Persisted in n8n workflow static data (`sd.lastProcessedDeploy`, `sd.lastProcessedAt`)
- **Note**: Requires Buffer profiles set up — if no profiles found, posts are drafted but not queued

### Current n8n Workflow IDs

| Workflow | Name | ID | Status |
|----------|------|----|--------|
| WF1 | Monday Content Research | `9roSxKaRZZGYpnEn` | ✅ Active |
| WF2 | Telegram Reply Handler | `BitiIHgtAwP1pAPN` | ✅ Active |
| N8 | Unified Article Writer | `RvnAoHhWRyFx10xu` | ✅ Active |
| N9 | Daily Morning Briefing | `gjo7ZtOLPv3fdulK` | ✅ Active |
| N10 | Marketing Agent | `G0yFabAVwCIANg4K` | ✅ Active |

**Deleted:** N5 (Sunday PM), N6 (Wednesday TT), N7 (Friday Invoicing)

---

## Infrastructure Reference

**n8n URL:** http://localhost:5678
**Deploy script:** `~/n8n-docker/deploy_v2.py`
**Article Writer webhook:** `http://localhost:5678/webhook/article-writer`
**Credentials:** `~/openclaw-docker/workspace/CREDENTIALS.local`

### Credential load order (first-occurrence-wins):
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

Keys: `GITHUB_TOKEN`, `NETLIFY_TOKEN`, `NETLIFY_SITE_ID`, `TAVILY_API_KEY`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`, `GEMINI_API_KEY`, `N8N_API_KEY`, `BUFFER_API_KEY`

---

## What to Do Next Session

### Session 4: QC Checker Workflow
Build n8n QC workflow that runs after each deploy:
1. Wait for Netlify `state: "ready"`
2. For each recently published article URL:
   - HTTP GET — verify 200 response
   - Check page source: no raw `{{<` shortcode text visible
   - Check page source: AdSense script present (`ca-pub-5124318262377242`)
   - Check content length (rough word count proxy)
3. Telegram: ✅ all checks passed OR ⚠️ specific failures

Coordinate with N10: both trigger on new Netlify deploy. QC runs after Marketing Agent.

### Known Issues
- Buffer profiles may not be configured yet — N10 will report "Buffer unavailable" until set up
- N8 Article Writer: for breaking news without a calendar slot (from morning briefing selections), extend WRITE command to also accept `{ "briefing_items": [...] }` input — partially scaffolded
- WF1 still uses `content/productivity-tools/` path correctly in Fetch Existing Articles node ✅
