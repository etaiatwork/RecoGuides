# SESSION_NOTES.md — RecoGuides
*Read this at the start of every session involving n8n or workflow automation.*

---

## Session: 2026-03-17 — n8n Foundation (WF1, WF2)

### What Was Built

Monday Content Research pipeline (WF1) + Telegram Reply Handler (WF2).

**WF1 flow:** Every Monday 8am ET → Tavily (7 products × 3 queries = 21 searches) → Fetch Existing Articles (GitHub tree API, `content/productivity-tools/`) → Gemini scoring + Jaccard dedup (threshold 0.45) → builds 3 fixed slots (Sunday=PM, Wednesday=TT, Friday=Invoicing) → pushes `workspace/calendar_state.json` + `workspace/CONTENT_CALENDAR.md` to GitHub → Telegram HTML message with dated slots.

**WF2 flow:** Polls every 2 minutes → handles `OK` (approve calendar) and `REPLACE [slot#] [title]` (swap slot + regenerate calendar + resend via Telegram).

**Workflow IDs (Session 2):**
- WF1 Monday Content Research: `9roSxKaRZZGYpnEn` ✅ still active
- WF2 Telegram Reply Handler: `4IPu8y21vF8fq6xS` — replaced Session 3

**Also deployed Session 2, then deleted Session 3:**
- N5: Sunday PM Article Writer
- N6: Wednesday TT Article Writer
- N7: Friday Invoicing Article Writer

**Known issue:** GITHUB_TOKEN duplicate in CREDENTIALS.local — line 1 is valid, line 8 was invalid duplicate. Python scripts use first-occurrence-wins. n8n container Docker env_file uses last-write-wins — may pick up wrong token. Fix: remove duplicate from CREDENTIALS.local, then `docker compose up -d --force-recreate` in `~/n8n-docker/`.

---

## Session: 2026-03-19 — Full Workflow Suite + Strategy Pivot

### Strategy Changes (MISSION.md + OPERATIONS.md Updated)

The entire content and business strategy was updated this session. Key changes:

| What Changed | Old | New |
|---|---|---|
| Author byline | Etai Ocarn | RecoGuides Team |
| Primary revenue | Affiliate commissions | Google AdSense (earns from day one) |
| Content model | Scheduled Sun/Wed/Fri | Daily briefing-driven (operator selects each morning) |
| Site identity | Affiliate review site | Daily intelligence source for SMB owners |
| Content focus | Freelancer SaaS tools | AI + technology for small/medium businesses |
| Frontmatter | No `summary` field | `summary` required (prevents Hugo schema errors) |
| Frontmatter | Had `categories:` field | No `categories:` field |
| Shortcodes | affiliate-cta only | Added vendor-link (inline), tweet embed |
| Article paths | `content/{category}/` | `content/productivity-tools/{subcategory}/` |

---

### New Daily Editorial Flow

This is how the site runs every day going forward:

```
7:00am ET   N9 fires → Tavily searches overnight AI/SMB news
            → Gemini compiles 8-10 headlines (Breaking + Evergreen)
            → Telegram digest sent to operator with numbered list

~7:05am     Operator replies with numbers e.g. "1 3 5"
            → WF2 saves selection to workspace/briefing_state.json
            → Operator replies "WRITE ALL" to start drafting

~7:10am     N8 Article Writer fires (webhook)
            → Reads calendar_state.json or briefing_state.json
            → Calls Gemini per article → writes full draft
            → Pre-publish checklist (affiliates.yaml scan)
            → Pushes each article to content/productivity-tools/{subcategory}/{slug}.md
            → Telegram confirmation per article

End of day  Operator triggers ONE GitHub push → ONE Netlify deploy
            (or deploy happens automatically from pushes)

~5 min      N10 Marketing Agent detects new deploy (state: "ready")
            → Pulls list of changed content/ files from recent commits
            → Gemini drafts LinkedIn post + Twitter/X post per article
            → Buffer API queues posts staggered (9am ET start, 2h apart)
            → Telegram: "📣 X posts queued to Buffer"

Operator replies SKIP at any point → WF2 cancels the day
```

Monday is special: WF1 also runs at 7am ET for weekly content calendar generation.

---

### All Workflows Built This Session

#### WF2 — Telegram Reply Handler (rebuilt)
**ID:** `BitiIHgtAwP1pAPN`
**Schedule:** Every 2 minutes (cron `*/2 * * * *`)
**Commands handled:**

| Command | Action |
|---------|--------|
| `OK` | Approve weekly content calendar |
| `REPLACE [#] [title]` | Swap calendar slot, regenerate, resend |
| `WRITE [#]` | Trigger Article Writer for one slot |
| `WRITE ALL` | Trigger Article Writer for all pending slots |
| `WRITE BREAKING` | Trigger Article Writer for breaking news only |
| `SKIP` | Cancel today's morning briefing |
| `1 3 5` (numbers) | Select articles from morning briefing |

WRITE commands call Article Writer via webhook: `http://localhost:5678/webhook/article-writer`

---

#### N8 — Unified Article Writer (new)
**ID:** `RvnAoHhWRyFx10xu`
**Trigger:** Webhook POST `http://localhost:5678/webhook/article-writer`
**Timeout:** 600 seconds

Input shapes:
```json
{ "slot": 1 }
{ "slots": [1, 2, 3] }
{ "write_all": true }
{ "type": "breaking" }
```

Flow:
1. Read `workspace/calendar_state.json` from GitHub
2. Determine target slots from input
3. For each slot: call Gemini with full article prompt (title, category, content type)
4. Gemini returns complete Hugo markdown with correct frontmatter
5. Pre-publish checklist: scan article for product names → check `data/affiliates.yaml` → add missing slugs as pending entries → push affiliates.yaml first
6. Push article to `content/productivity-tools/{subcategory}/{slug}.md`
7. Update `calendar_state.json` (mark slot `status: "written"`)
8. Telegram confirmation per article

Frontmatter generated:
```yaml
author: "RecoGuides Team"
summary: "[required — same as description]"
verticals: ["productivity-tools"]
# no categories field
```

Shortcodes used:
- `{{< vendor-link "slug" >}}Text{{< /vendor-link >}}` — first AND last mention of each product
- `{{< affiliate-cta "slug" >}}` — after each product section
- `{{< affiliate-table "slug1,slug2" >}}` — near top of comparison articles
- `{{< tweet user="x" id="y" >}}` — in breaking news and weekly digest

Content type word targets: BREAKING=800-1000, EVERGREEN=1500-1800, DIGEST=800-1000

---

#### N9 — Daily Morning Briefing (new)
**ID:** `gjo7ZtOLPv3fdulK`
**Schedule:** Every day 7am ET (cron `0 7 * * *`)

Flow:
1. Tavily searches 9 queries (AI/SMB news, `days: 1`) — deduplicates by URL
2. Gemini compiles 8-10 headlines, separates Breaking News vs Evergreen/Trending
3. Saves `workspace/briefing_state.json` to GitHub with `status: "awaiting_selection"`
4. Sends Telegram numbered digest:

```
☀️ Morning Briefing — Thursday, March 19, 2026

🔥 Breaking News
1. [headline] — [why it matters]
2. [headline] — [why it matters]

📌 Evergreen / Trending
3. [headline] — [subcategory]
...

─────────────────
Reply with numbers to select e.g. 1 3 5
Reply SKIP to cancel today.
```

State file: `workspace/briefing_state.json`
After number selection: items saved to `briefing_state.selected[]`
After SKIP: `briefing_state.skipped = true`, `status: "skipped"`

---

#### N10 — Marketing Agent (new)
**ID:** `G0yFabAVwCIANg4K`
**Schedule:** Every 5 minutes (cron `*/5 * * * *`)

Flow:
1. GET latest Netlify deploy via API
2. Check `state === "ready"` and `deploy.id !== sd.lastProcessedDeploy`
3. If new deploy: fetch commits to `content/` since last run → extract changed `.md` files
4. For each article: fetch file from GitHub, extract title + description
5. Gemini generates LinkedIn post (150-200 chars + hashtags) + Twitter/X post (under 240 chars)
6. GET Buffer profiles: `https://api.bufferapp.com/1/profiles.json?access_token={BUFFER_API_KEY}`
7. POST each post to Buffer with staggered `scheduled_at` (9am ET base + 2h per article)
8. Mark deploy as processed in static data
9. Telegram: confirms articles processed + posts queued (or warns if Buffer unavailable)

**Buffer API endpoints:**
- Profiles: `GET https://api.bufferapp.com/1/profiles.json?access_token={token}`
- Create update: `POST https://api.bufferapp.com/1/updates/create.json` (form-encoded: `access_token`, `profile_ids[]`, `text`, `scheduled_at`, `now=false`)

**⚠️ Buffer setup required:** Profiles must exist in Buffer account for N10 to queue posts. Without profiles, N10 drafts posts but cannot queue them. See next session setup steps.

---

### AdSense Added

**File:** `layouts/partials/extend_head.html`
**Publisher ID:** `ca-pub-5124318262377242`
**Script:**
```html
<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-5124318262377242" crossorigin="anonymous"></script>
```

This file is loaded by PaperMod's `extend_head` partial hook — injects into `<head>` on every page automatically. Do not delete this file.

AdSense approval status: pending — Google reviews new sites before serving ads. Ads will not appear until approved.

---

### Complete Workflow ID Reference (as of 2026-03-19)

| ID | Workflow | Schedule | Status |
|----|----------|----------|--------|
| `9roSxKaRZZGYpnEn` | WF1 — Monday Content Research | Monday 7am ET | ✅ Active |
| `BitiIHgtAwP1pAPN` | WF2 — Telegram Reply Handler | Every 2 min | ✅ Active |
| `RvnAoHhWRyFx10xu` | N8 — Unified Article Writer | On demand (webhook) | ✅ Active |
| `gjo7ZtOLPv3fdulK` | N9 — Daily Morning Briefing | Daily 7am ET | ✅ Active |
| `G0yFabAVwCIANg4K` | N10 — Marketing Agent | Every 5 min | ✅ Active |

Deleted this session: N5 (Sunday PM), N6 (Wednesday TT), N7 (Friday Invoicing)

Deploy script: `~/n8n-docker/deploy_v2.py` — redeploys all v2 workflows from scratch if needed.

---

## Session: 2026-03-21 — Infrastructure Fixes + Scheduled Publishing

### Task 1: GITHUB_TOKEN Duplicate
No duplicate found — CREDENTIALS.local was already clean. n8n restarted to pick up clean env.

### Task 2: N9 Daily Morning Briefing — Root Cause
**Root cause**: n8n container crashed between Friday 7am and Saturday 7am.
- Friday March 20: N9 fired at 7am ET but execution errored in 17ms (crash in progress)
- Saturday March 21: n8n was down/restarted — NO execution recorded (n8n doesn't catch up missed crons)
- n8n logs show: "Last session crashed"
**Fix**: n8n restarted clean. N9 is active and will fire Sunday March 22 at 7am ET.
**Prevention note**: If n8n crashes, the next scheduled run will be missed. No automatic recovery.

### Task 3: Force Light Mode
Added `defaultTheme = "light"` to `~/RecoGuides/config.toml`.
`disableThemeToggle = true` was already set. Site now always loads light regardless of OS setting.

### Task 4: Scheduled Publishing

#### How it works:
1. Operator selects articles with optional date suffix:
   - `1 3` → publishes both today
   - `2 TOMORROW` → publishes item 2 tomorrow
   - `4 SAT` → this Saturday (or next if already past)
   - `5 2026-03-28` → exact date
   - Day keywords: MON/TUE/WED/THU/FRI/SAT/SUN
2. WF2 saves publishDate to each item in briefing_state.json
3. Operator sends `WRITE ALL` → WF2 passes briefing_items (with publishDate) to N8
4. N8 writes article with `date: YYYY-MM-DDT12:00:00Z` in Hugo frontmatter
5. Future-dated articles tracked in `workspace/schedule_state.json`
6. Hugo natively holds future-dated articles until their publish date

#### SCHEDULE OFF command:
- Send: `SCHEDULE OFF 2026-03-28 TO 2026-03-30`
- WF2 saves to `blackoutDates[]` in calendar_state.json
- N9 daily briefing checks for upcoming blackouts (warns 7 days in advance)

#### Daily briefing enhancements:
- Checks schedule_state.json → shows "Going Live Today" section for future-dated articles
- Checks calendar_state.json → shows "Schedule Reminder" for upcoming blackout dates
- Updated reply instructions include date format examples

#### New file: workspace/schedule_state.json
Tracks all future-dated articles:
```json
{
  "scheduled": [
    { "publishDate": "2026-03-28", "title": "...", "path": "content/...", "writtenAt": "..." }
  ]
}
```

#### Workflow IDs (unchanged):
| ID | Workflow | Changes |
|----|----------|---------|
| BitiIHgtAwP1pAPN | WF2 — Telegram Reply Handler | Date parsing + SCHEDULE_OFF + briefing_items pass-through |
| RvnAoHhWRyFx10xu | N8 — Unified Article Writer | briefing_items path + schedule_state tracking |
| gjo7ZtOLPv3fdulK | N9 — Daily Morning Briefing | todayAlerts + blackoutAlerts in briefing |

---

## Session: 2026-03-22 — Missed-Run Watchdog + BRIEF Command

### Context: The Missed-Run Problem

n8n CE does **not** catch up missed cron runs after a container crash or restart. If n8n is down at 7am ET, that day's briefing is silently skipped with no alert. Root cause was confirmed in Session 4: Friday crash caused Saturday briefing miss. This session adds automatic detection and recovery.

**Additional context:** Operator observes Sabbath (Friday sundown to Saturday night). The machine may be off or unmonitored during this window. Any briefing that fires Saturday morning before machine comes back will be missed. The watchdog handles this — if n8n restarts Saturday and N9 missed its 7am run, the watchdog fires it automatically before 11am, or warns via Telegram after 11am for BRIEF-on-demand recovery.

---

### What Was Built

#### N9 — Daily Morning Briefing (updated)
**New ID:** `pk2Gvf0rWSCbNJvB` (old: `gjo7ZtOLPv3fdulK`)
**Change:** Added webhook trigger at `POST /webhook/morning-briefing`
- Cron trigger (7am ET daily) preserved — unchanged behavior
- Webhook trigger fires the same "Fetch News & Send Briefing" code node
- `responseMode: onReceived` — responds 200 immediately, runs async
- Deploy script: `~/n8n-docker/deploy_watchdog.py`

#### N11 — Missed-Run Watchdog (new)
**ID:** `kkstWmRQgTMsVlBv`
**Schedule:** Every 30 minutes (`*/30 * * * *`)

Flow:
1. Look up N9's workflow ID by name via n8n API (robust: survives re-deployments)
2. Fetch last 10 executions for N9
3. Check if any execution has `status: success` or `status: running` AND `startedAt` date = today in ET
4. If N9 already ran → exit silently
5. If N9 has NOT run:
   - Before 11am ET → POST to `http://localhost:5678/webhook/morning-briefing` (auto-recover)
   - After 11am ET → Telegram: "⚠️ Today's briefing was missed. Reply BRIEF to get today's headlines now."

**Why by-name lookup:** If N9 is ever re-deployed (changing its ID), the watchdog still works without needing a code update.

#### WF2 — Telegram Reply Handler (updated)
**New ID:** `ue1BErcKQilsVi1h` (old: `BitiIHgtAwP1pAPN`)
**New command: `BRIEF`**

| Command | Action |
|---------|--------|
| `BRIEF` | POST to `/webhook/morning-briefing` — triggers N9 on demand at any time |

All previous commands (OK, REPLACE, WRITE, SKIP, SCHEDULE OFF, number selection) preserved unchanged.

---

### Updated Workflow ID Reference (as of 2026-03-22)

| ID | Workflow | Schedule | Status |
|----|----------|----------|--------|
| `9roSxKaRZZGYpnEn` | WF1 — Monday Content Research | Monday 7am ET | ✅ Active |
| `ue1BErcKQilsVi1h` | WF2 — Telegram Reply Handler | Every 2 min | ✅ Active |
| `RvnAoHhWRyFx10xu` | N8 — Unified Article Writer | On demand (webhook) | ✅ Active |
| `pk2Gvf0rWSCbNJvB` | N9 — Daily Morning Briefing | 7am ET + webhook | ✅ Active |
| `G0yFabAVwCIANg4K` | N10 — Marketing Agent | Every 5 min | ✅ Active |
| `kkstWmRQgTMsVlBv` | N11 — Missed-Run Watchdog | Every 30 min | ✅ Active |

N9 webhook URL: `http://localhost:5678/webhook/morning-briefing`

---

### Operator Notes

- **Sabbath observance:** Machine may be off Friday sundown (~5:30pm ET winter / ~7:30pm ET summer) through Saturday night. Any Saturday briefing missed while machine was down will be auto-recovered by watchdog when n8n restarts (before 11am), or queued for BRIEF reply (after 11am).
- **BRIEF command:** Works at any time, any day — not just for missed runs. Useful whenever operator wants a fresh briefing outside the 7am schedule.
- **Watchdog silent on success:** If N9 already ran, watchdog exits with no Telegram message. Only fires if there's a problem.

---

## Next Session: Test Full Monday Pipeline End to End

**Goal:** Confirm the complete Monday → article → deploy → social loop works without manual intervention.

### Step-by-step test plan:

**1. Fix GITHUB_TOKEN duplicate (do this first)**
```bash
# Open CREDENTIALS.local, remove the duplicate GITHUB_TOKEN line (line ~8)
# Only line 1 should have GITHUB_TOKEN
nano ~/openclaw-docker/workspace/CREDENTIALS.local
# Then recreate n8n container so it picks up clean env
cd ~/n8n-docker && docker compose up -d --force-recreate
```

**2. Regenerate n8n API key**
- Go to http://localhost:5678 → Settings → API
- Generate new key, update `N8N_API_KEY` in `~/n8n-docker/.env`
- Update `WF2_ID` at top of `deploy_v2.py` if re-running

**3. Manually trigger WF1 (Monday Content Research)**
- Open http://localhost:5678/workflow/9roSxKaRZZGYpnEn
- Click "Test workflow" / execute manually
- Expected: Tavily searches run → Gemini scores → calendar pushed to GitHub → Telegram message arrives

**4. Test OK reply**
- Reply `OK` in Telegram
- Expected: WF2 picks it up within 2 minutes → "Calendar approved!" confirmation

**5. Test WRITE**
- Reply `WRITE 1` in Telegram
- Expected: WF2 calls N8 webhook → N8 reads calendar → Gemini writes article → pushed to `content/productivity-tools/...` → Telegram "✅ Article pushed" confirmation

**6. Verify article on GitHub**
- Check `https://github.com/etaiatwork/RecoGuides/tree/main/content/productivity-tools`
- Open article — verify frontmatter has `author: "RecoGuides Team"`, `summary:` field present, correct shortcodes

**7. Check Netlify deploy**
- Netlify auto-deploys on GitHub push
- Go to Netlify dashboard or check: `GET https://api.netlify.com/api/v1/sites/{NETLIFY_SITE_ID}/deploys?per_page=1`
- Wait for `state: "ready"`

**8. Test N9 Morning Briefing (manual trigger)**
- Open http://localhost:5678/workflow/gjo7ZtOLPv3fdulK → execute manually
- Expected: Telegram briefing arrives with numbered headlines

**9. Test number selection**
- Reply `1 3` in Telegram
- Expected: WF2 picks up numbers → saves to `briefing_state.json` → Telegram confirms selection

**10. Test N10 Marketing Agent**
- After Netlify deploy is `ready`: wait up to 5 minutes
- Expected: Telegram "📣 Marketing Agent" message confirming posts queued
- If Buffer not set up yet: message should say "Buffer unavailable" but not crash

**11. Set up Buffer (if not done)**
- Go to buffer.com → connect LinkedIn and Twitter/X accounts
- Confirm `BUFFER_API_KEY` in CREDENTIALS.local is the correct access token
- Test: `curl "https://api.bufferapp.com/1/profiles.json?access_token={BUFFER_API_KEY}"`
- Should return JSON array of profile objects with `id` fields

### What "success" looks like:
- ✅ Telegram briefing arrives at 7am
- ✅ Operator number reply saves to briefing_state.json
- ✅ WRITE triggers article → article appears on GitHub with correct frontmatter
- ✅ Netlify deploys article to recoguides.com
- ✅ N10 queues social posts to Buffer within 5 minutes of deploy
- ✅ Operator receives Telegram confirmations at each step

---

---

## Session: 2026-03-22 — Command Routing Fix (Session 6)

### Problem

BRIEF and all other n8n commands sent via Telegram were being intercepted by OpenClaw instead of reaching WF2. OpenClaw responded conversationally.

### Root Cause

Two competing Telegram `getUpdates` consumers on the same bot token:
1. **Grammy (OpenClaw)** — long-poll, `timeout=30`, monopolizes the connection
2. **WF2 (n8n cron)** — every 2 minutes, `timeout=0` short-poll

Grammy always held the slot first. WF2 got empty results or 409 Conflict. OpenClaw received every message and processed it through the AI pipeline.

### What Was Built

#### Phase 1: telegram-router service (abandoned)
Created `~/telegram-router/router.py` — standalone short-poll Python service that detects n8n command patterns and forwards to WF2 webhook. Installed as user systemd service.

**Problem:** Grammy's long-poll monopolizes Telegram entirely. Even `timeout=0` calls get HTTP 409 Conflict when Grammy has an active connection. The router was getting 409 continuously. **Abandoned.**

#### Phase 2: WF2 rebuilt with webhook trigger
`deploy_s6_router.py` rebuilt WF2:
- Removed cron + getUpdates polling from WF2
- Added webhook trigger at `POST /webhook/wf2-router-in`
- All command parsing logic unchanged

**New WF2 ID:** `Y37niVPuXzXpUJSY`

#### Phase 3: n8n webhook 404 bug fix (root cause in n8n 2.x)

**Bug:** n8n 2.12.2 uses Express 5. `getNodeWebhookPath()` stores webhook paths as `workflowId/encodeURIComponent(nodeName)/path` (e.g., `pk2G.../webhook%20trigger/morning-briefing`). Express 5 URL-decodes path params before lookup → stored `%20` ≠ decoded space → **every webhook was 404**.

**Fix:** Add `webhookId` to each webhook node. When `webhookId` is set + `isFullPath=true` (default for n8n-nodes-base.webhook), `getNodeWebhookPath` returns just `path` directly. URL is simply `/webhook/path-name`.

Applied to:
- N9 webhook node: `webhookId: "morning-briefing-n9"`
- WF2 webhook node: `webhookId: "wf2-router-in"`
- N8 webhook node: `webhookId: "article-writer"`

Then deactivated/reactivated each workflow to re-register webhooks.

**Result:** All three webhooks now return HTTP 200.

#### Phase 4: OpenClaw as the router

Updated `N8N_ROUTING.md` to instruct OpenClaw to:
1. When it receives an n8n command, use `exec` tool to `curl http://localhost:5678/webhook/wf2-router-in`
2. Then produce zero Telegram output

This uses Grammy's existing long-poll (which always works) as the message receiver. OpenClaw exec-forwards commands to WF2, then stays silent. WF2 handles all replies.

### Final Architecture

```
Telegram message
  → Grammy (OpenClaw long-poll) receives it
  → OpenClaw checks N8N_ROUTING.md
  → If n8n command: exec curl → WF2 webhook → n8n processes → Telegram reply
  → If real message: OpenClaw responds normally
```

### Updated Workflow ID Reference (as of 2026-03-22 Session 6)

| ID | Workflow | Trigger | Status |
|----|----------|---------|--------|
| `9roSxKaRZZGYpnEn` | WF1 — Monday Content Research | Monday 7am ET | ✅ Active |
| `Y37niVPuXzXpUJSY` | WF2 — Telegram Reply Handler | POST /webhook/wf2-router-in | ✅ Active |
| `RvnAoHhWRyFx10xu` | N8 — Unified Article Writer | POST /webhook/article-writer | ✅ Active |
| `pk2Gvf0rWSCbNJvB` | N9 — Daily Morning Briefing | 7am ET + /webhook/morning-briefing | ✅ Active |
| `G0yFabAVwCIANg4K` | N10 — Marketing Agent | Every 5 min | ✅ Active |
| `kkstWmRQgTMsVlBv` | N11 — Missed-Run Watchdog | Every 30 min | ✅ Active |

All webhook URLs confirmed working (HTTP 200).

### N8N_ROUTING.md Change

Updated to include exec-forward instruction. When OpenClaw sees an n8n command pattern, it runs:
```bash
curl -s -X POST http://localhost:5678/webhook/wf2-router-in \
  -H "Content-Type: application/json" \
  -d '{"text":"<THE_MESSAGE>","chat_id":"6424406212"}'
```
Then sends nothing back to Telegram.

---

## Infrastructure Quick Reference

| Thing | Location |
|-------|----------|
| n8n UI | http://localhost:5678 |
| Deploy script | `~/n8n-docker/deploy_v2.py` |
| GitHub push script | `~/n8n-docker/push_to_github.py` |
| Article Writer webhook | `http://localhost:5678/webhook/article-writer` |
| Morning Briefing webhook | `http://localhost:5678/webhook/morning-briefing` |
| WF2 Router webhook | `http://localhost:5678/webhook/wf2-router-in` |
| Credentials | `~/openclaw-docker/workspace/CREDENTIALS.local` |
| Hugo site repo | `~/RecoGuides/` |
| Workspace (authoritative) | `~/openclaw-docker/workspace/` |
| Workspace (GitHub copy) | `~/RecoGuides/workspace/` |

Credential keys available: `GITHUB_TOKEN`, `NETLIFY_TOKEN`, `NETLIFY_SITE_ID`, `TAVILY_API_KEY`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`, `GEMINI_API_KEY`, `N8N_API_KEY`, `BUFFER_API_KEY`, `LINKEDIN_ID`, `TWITTER_CONSUMER_KEY`, `TWITTER_CLIENT_SECRET`, `TWITTER_BEARER_TOKEN`
