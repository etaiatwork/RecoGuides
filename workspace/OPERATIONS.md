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
"state": "ready" = success. "state": "error" = failed.

### CRITICAL: One deploy per day maximum
Never trigger more than one Netlify deploy per session. Batch ALL file changes into a single GitHub push first, then trigger one deploy at the end.

### Python push script (use this — more reliable than curl):
```python
import urllib.request, json, base64

with open('/home/node/.openclaw/workspace/CREDENTIALS.local') as f:
    creds = {}
    for line in f:
        if '=' in line:
            k,v = line.strip().split('=',1)
            creds[k] = v

with open('/path/to/local/file','rb') as f:
    content = f.read()

encoded = base64.b64encode(content).decode('utf-8')
data = json.dumps({"message": "commit message", "content": encoded}).encode('utf-8')

req = urllib.request.Request(
    f'https://api.github.com/repos/etaiatwork/RecoGuides/contents/{github_path}',
    data=data,
    headers={'Authorization': f'token {creds["GITHUB_TOKEN"]}', 'Content-Type': 'application/json'},
    method='PUT'
)
resp = urllib.request.urlopen(req)
result = json.loads(resp.read())
print("Commit SHA:", result['commit']['sha'])
```

---

## Site File Structure

```
RecoGuides/
├── config.toml                              # Site config, taxonomies, menu
├── .gitignore                               # Excludes public/, .hugo_build.lock
├── netlify.toml                             # Build config — Hugo 0.146.0
├── archetypes/
│   └── default.md                           # Frontmatter template
├── assets/
│   └── css/
│       └── extended/
│           └── custom.css                   # Custom CSS overrides
├── content/
│   ├── about.md
│   ├── contact.md
│   ├── categories.md                        # Categories landing page
│   ├── _index.md
│   └── productivity-tools/                  # Vertical 1
│       ├── _index.md
│       ├── project-management/
│       │   ├── _index.md
│       │   └── [articles].md
│       ├── time-tracking/
│       │   ├── _index.md
│       │   └── [articles].md
│       └── invoicing/
│           ├── _index.md
│           └── [articles].md
├── data/
│   └── affiliates.yaml                      # Central affiliate database
├── layouts/
│   ├── index.html                           # Homepage template
│   ├── categories.html                      # Categories landing page template
│   ├── shortcodes/
│   │   ├── affiliate-cta.html               # Single product CTA
│   │   ├── affiliate-table.html             # Multi-product comparison table
│   │   └── vendor-link.html                 # Inline vendor hyperlink shortcode
│   └── partials/
│       ├── extend_head.html                 # AdSense script (do not delete)
│       └── templates/
│           └── schema_json.html             # Custom schema (fixes Hugo minifier bug)
├── themes/
│   └── PaperMod/                            # Git submodule
└── workspace/                               # Agent memory (not deployed)
    ├── MISSION.md
    ├── OPERATIONS.md
    ├── TASK_LOG.md
    ├── SESSION_NOTES.md
    ├── CONTENT_CALENDAR.md                  # Generated weekly by n8n
    └── CREDENTIALS.local                    # Never push this file
```

---

## Adding a New Vertical
When operator approves a new vertical:
1. Create content/{vertical-slug}/_index.md with title and description
2. Create content/{vertical-slug}/{subcategory}/_index.md for each subcategory
3. Add affiliate products to data/affiliates.yaml
4. Update layouts/categories.html to add new vertical card
5. Update content/categories.md if needed
6. Begin writing articles with correct path: content/{vertical-slug}/{subcategory}/{slug}.md
No config.toml changes needed — Hugo handles taxonomies automatically.

---

## Standard Article Frontmatter
Every article must use this exact schema:

```yaml
---
title: ""
date: YYYY-MM-DDTHH:MM:SSZ
draft: false
author: "RecoGuides Team"
description: "One sentence description for SEO and homepage snippet."
summary: "Same as description or slightly shorter — required to prevent Hugo schema errors."
featured_image: ""
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

**Important**: `summary` field is required. Without it Hugo's schema_json.html template throws a build error on Netlify.

---

## Shortcode Usage

### Inline vendor hyperlink (first AND last mention of every vendor):
```
{{< vendor-link "clickup" >}}ClickUp{{< /vendor-link >}}
```
- If status is active → links to affiliateUrl
- If status is pending → links to websiteUrl
- If slug not found → renders plain text, no error

### Single product CTA (place after each product section):
```
{{< affiliate-cta "clickup" >}}
```

### Comparison table (place near top of comparison articles):
```
{{< affiliate-table "clickup,asana,monday" >}}
```

### Tweet embedding (use in breaking news and weekly digest articles):
```
{{< tweet user="username" id="tweetid" >}}
```

### Valid product slugs:
`clickup`, `asana`, `monday`, `freshbooks`, `toggl`, `harvest`, `clockify`, `wave`
Add new slugs to data/affiliates.yaml as new products are mentioned.

---

## Affiliate Data File Structure
Each product in data/affiliates.yaml:

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
  cons:
    - Con 1
```

When affiliate approved: update `status: active` and `affiliateUrl`. All articles update automatically.

### Affiliate Intake Command
Send via Telegram: `ADD AFFILIATE [company] [websiteUrl] [affiliateUrl or PENDING] [commission]`
Etai auto-slugifies, adds YAML entry, pushes to GitHub, confirms via Telegram.

---

## Content Calendar Format
File: workspace/CONTENT_CALENDAR.md
Generated every Monday by n8n Research Agent.

```markdown
# RecoGuides Content Calendar

## Week of [DATE]

## 🔥 Breaking News — Write First
| # | Day | Title | Product | Score |

## 📅 Evergreen Queue
| # | Day | Title | Product(s) | Category | Score |

## ✅ Approval Status
Status: PENDING OPERATOR REVIEW
Reply OK to approve or REPLACE [slot#] [new title] to swap.
```

Etai must check Approval Status before writing. Do not write if PENDING.

---

## Daily Briefing Format
Sent every morning at 7am ET via Telegram.

```
📋 RecoGuides Daily Briefing — [DATE]

🔥 Breaking News:
1. [Headline] — [one line why it matters]
2. [Headline] — [one line why it matters]

📝 Evergreen Opportunities:
3. [Headline] — [subcategory]
4. [Headline] — [subcategory]
5. [Headline] — [subcategory]

Reply with numbers to select e.g. "1, 3, 5"
Reply SKIP to publish nothing today.
```

---

## n8n Workflow System
- n8n running at http://localhost:5678
- Docker location: ~/n8n-docker/
- Credentials: ~/openclaw-docker/workspace/CREDENTIALS.local (loaded via docker-compose env_file with absolute path)
- Timezone: America/New_York (ET)

### Active Workflows (current — to be cleaned up):
| ID | Name | Schedule | Status |
|----|------|----------|--------|
| 9roSxKaRZZGYpnEn | Monday Content Research | Monday 7am ET | ✅ Active |
| 4IPu8y21vF8fq6xS | Telegram Reply Handler | Polling every 2min | ✅ Active |
| nGDPGYr3phHsEnkB | N5: Sunday PM Article Writer | Sunday 8am ET | ⚠️ To be replaced |
| oJj2xfABVYz6LaJG | N6: Wednesday TT Article Writer | Wednesday 8am ET | ⚠️ To be replaced |
| G36vfrSk2rFIFMKy | N7: Friday Invoicing Article Writer | Friday 8am ET | ⚠️ To be replaced |

### Target Workflow Structure (clean):
| Workflow | Purpose | Schedule |
|----------|---------|----------|
| Monday Content Research | Weekly calendar + Telegram approval loop | Monday 7am ET |
| Telegram Reply Handler | Handles OK/REPLACE/number/SKIP replies | Polling every 2min |
| Daily Morning Briefing | Tavily search, headline digest to Telegram | Daily 7am ET |
| Article Writer | Writes any content type based on operator selection | Triggered on demand |
| Marketing Agent | Queues Buffer posts after deploy | Triggered after deploy |
| QC Checker | Verifies deploy succeeded | Triggered after deploy |

N5, N6, N7 to be deleted and replaced with unified Article Writer workflow.

---

## News Search Protocol
Search scope: AI tools, SMB technology, productivity software, business software trends
Plus specific products: ClickUp, Asana, Monday.com, FreshBooks, Toggl, Harvest, Clockify, Wave

Search queries:
- "AI small business tools [current month year]"
- "SMB technology news [current month year]"
- "[Product name] update [current month year]"
- "[Product name] new feature [current month year]"

Priority: breaking news → write same day. Evergreen fills remaining slots.

---

## Social Posting Protocol
- All articles deploy in ONE batch per day maximum
- Buffer API queues LinkedIn and Twitter/X posts
- Posts staggered: first post 1 hour after deploy, then every 2-3 hours
- Never post all social content simultaneously
- Reddit: operator manually approves every post — never auto-post

### Buffer API Usage:
```
POST https://api.bufferapp.com/1/updates/create.json
Authorization: Bearer {BUFFER_API_KEY}
Body: { "profile_ids": [...], "text": "...", "scheduled_at": "ISO8601" }
```

---

## Hugo Build Rules (Known Issues)
- Theme is PaperMod (NOT hello-friend-ng — that was the old theme)
- Hugo version: 0.146.0 (set in netlify.toml)
- `summary` field required in all article frontmatter — missing it causes schema_json build errors
- `draft: false` must be set explicitly
- Date format: `2026-03-07T13:57:00Z`
- Shortcodes use straight quotes only: `{{< affiliate-cta "clickup" >}}` not smart quotes
- Theme loads via git submodule — netlify.toml has: `git submodule update --init --recursive &&` before hugo command
- Do NOT commit public/ or .hugo_build.lock — covered by .gitignore
- schema_json.html is overridden in layouts/partials/templates/ — do not delete
- AdSense script in layouts/partials/extend_head.html — do not delete

---

## Task Log Protocol
After completing ANY task:
1. Mark completed items ✅ with date
2. Update "Current State" section
3. Add newly discovered tasks
4. Note blockers or errors
5. Commit TASK_LOG.md to GitHub after every update

---

## Vertical Pitch Document Format
```
# Vertical Pitch: [Niche Name]

## Opportunity Summary
[2-3 sentences]

## Top 5 Target Keywords
| Keyword | Est. Monthly Searches | Competition |

## Top Affiliate Programs
| Program | Commission | Network |

## Revenue Estimate
[At 0.875% conversion]

## Proposed First 10 Articles
1-10.

## Verdict: GO / NO-GO
[Reasoning]
```
