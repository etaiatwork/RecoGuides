# SESSION_NOTES.md — RecoGuides
*Read this at the start of every session involving n8n or workflow automation.*

---

## Session: 2026-03-17 — n8n Automation Build (N1–N3)

### What Was Built

A fully automated Monday content research pipeline running in n8n (Docker, port 5678).

**Pipeline flow (Workflow 1 — Monday Content Research):**

1. **Every Monday 8am ET** — Schedule trigger
2. **Search All Products** — Tavily API: 7 products × 3 query types = 21 searches, `days: 7`
3. **Fetch Existing Articles** — GitHub Git Tree API lists all `.md` files under `content/productivity-tools/`, fetches each one, extracts `title` and `slug` from frontmatter
4. **Score with Gemini** — Sends news items + existing article list to `gemini-2.0-flash`. Asks for 6 ordered suggestions (2 per slot category as dedup backups). Runs Jaccard similarity dedup (threshold 0.45) + slug-based match against existing articles. Fills 3 slots by category: `[project-management, time-tracking, invoicing]`. Falls back to hardcoded suggestions if Gemini 429s.
5. **Generate & Push Calendar** — Builds `CONTENT_CALENDAR.md` + `calendar_state.json`, pushes both to GitHub at `workspace/`. Fixed slot schedule: Sunday +6 = Project Management, Wednesday +9 = Time Tracking, Friday +11 = Invoicing. Breaking news gets today's date.
6. **Format Telegram Report** — Builds HTML message with dated slots
7. **Send to Telegram** — Delivers via Bot API

**Telegram message format:**
```
📋 Monday Content Research
Monday, March 23, 2026

🔥 BREAKING — Monday March 23:
[headline]

📅 Sunday March 29 — Project Management:
[title]

📅 Wednesday April 1 — Time Tracking:
[title]

📅 Friday April 3 — Invoicing:
[title]

─────────────────
Reply OK to approve or REPLACE 2 New Title Here to swap a slot.
📁 Pushed → workspace/CONTENT_CALENDAR.md
```

**Pipeline flow (Workflow 2 — Telegram Reply Handler):**

- Runs every 2 minutes
- Polls `getUpdates` with persistent `lastUpdateId` via `$getWorkflowStaticData`
- `OK` → marks `calendar_state.json` approved, sends confirmation with full dated slot list
- `REPLACE [slot#] [new title]` → swaps title in state + regenerates `CONTENT_CALENDAR.md`, resends updated calendar

---

## Current n8n Workflow IDs

| Workflow | Name | ID | Status |
|----------|------|----|--------|
| WF1 | Monday Content Research | `9roSxKaRZZGYpnEn` | ✅ Active |
| WF2 | Telegram Reply Handler | `4IPu8y21vF8fq6xS` | ✅ Active |

**n8n URL:** http://localhost:5678
**Deploy script:** `~/n8n-docker/update_workflow.py`
**After each deploy:** update `WF1_ID` in `update_workflow.py` to the new ID printed by the script.

---

## Known Issues

1. **GITHUB_TOKEN duplicate in CREDENTIALS.local** — Line 1 has the valid token (`ghp_QMeTSf...`), line 8 has an invalid duplicate that overrides it in Docker's `env_file` (last-write-wins). The n8n container uses the invalid token. Fix: remove line 8 from `CREDENTIALS.local`, then run `docker compose up -d --force-recreate` in `~/n8n-docker/`. Until fixed, all GitHub operations inside n8n workflows (Fetch Existing Articles, push calendar) will fail with 401. The rest of the pipeline (Tavily, Gemini, Telegram) is unaffected.

2. **Gemini 429 rate limiting in testing** — Free tier quota exhausted quickly during repeated test runs. Not an issue in production (runs once per week). The workflow falls back to hardcoded suggestions and the dedup still runs.

3. **WF1_ID hardcoded in update_workflow.py** — Every deploy creates a new workflow with a new ID. The old ID must be updated manually at the top of the script. The script saves the new ID to `/tmp/wf1_id.txt` after each run as a reminder.

4. **content/productivity-tools/ path** — The Fetch Existing Articles node filters for `content/productivity-tools/`. All current articles were written to `content/project-management/`, `content/time-tracking/`, and `content/invoicing/`. If articles are not under `productivity-tools/`, the dedup node will find 0 existing articles and skip dedup. **Confirm correct path before next Monday run.**

---

## What to Do Next Session (N4–N7)

These are the writing-trigger tasks — using the approved content calendar to actually write and publish articles.

### N4 — Wire calendar approval to article writing
When the operator sends `OK`, the workflow currently just marks the calendar approved. N4 adds the next step: trigger article drafting for each approved slot.

Options:
- **Option A (manual):** Operator reads the approved calendar and starts a Claude Code session, passing the approved slot titles as the article brief.
- **Option B (automated):** After `OK`, Workflow 2 creates a GitHub Issue per slot with the title, category, and target publish date as the brief. Claude Code sessions pick up open issues.
- **Recommended: Option A for now** — keeps operator in the loop, no extra infrastructure.

### N5 — Article writing workflow
For each approved slot:
1. Read `workspace/CONTENT_CALENDAR.md` to get the current week's titles
2. For each article: write full draft following OPERATIONS.md standards (frontmatter, affiliate shortcodes, affiliate-table for comparisons)
3. Run pre-publish checklist (scan for vendors, update `data/affiliates.yaml` if needed)
4. Push to correct path under `content/{category}/`

Priority order: BREAKING first, then Sunday → Wednesday → Friday.

### N6 — Auto-publish trigger
After article is pushed to GitHub, Netlify auto-deploys (already wired). But n8n could optionally:
- Verify the Netlify deploy completed (`state: "ready"`)
- Send a Telegram confirmation: "✅ Article live: [title] — [URL]"

Netlify API: `GET https://api.netlify.com/api/v1/sites/{NETLIFY_SITE_ID}/deploys?per_page=1`

### N7 — Weekly metrics check (future)
After each publishing week, pull basic stats and send a Telegram summary:
- Articles published this week
- Netlify deploy status
- Affiliate links active vs pending

---

## Credentials Reference

All credentials live in **`~/openclaw-docker/workspace/CREDENTIALS.local`**.
When loading in Python, always use **first-occurrence-wins** (load CREDENTIALS.local before .env) to get the valid GITHUB_TOKEN from line 1.

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

Keys available: `GITHUB_TOKEN`, `NETLIFY_TOKEN`, `NETLIFY_SITE_ID`, `TAVILY_API_KEY`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`, `GEMINI_API_KEY`, `N8N_API_KEY`
