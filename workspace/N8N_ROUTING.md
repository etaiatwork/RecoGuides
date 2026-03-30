# N8N_ROUTING.md — Automation Command Passthrough

## HARD RULE: Route These Messages to n8n, Then Stay Silent

The n8n workflow automation system handles the following Telegram messages.
When you receive a message that **exactly matches** one of the patterns below,
you **MUST**:
1. Use `exec` to forward it to n8n: `curl -s -X POST http://localhost:5678/webhook/wf2-router-in -H "Content-Type: application/json" -d '{"text":"<THE_MESSAGE>","chat_id":"6424406212"}'`
2. **Then produce zero output.** Zero words. No acknowledgment. No "I see you sent...". No "Sure!". Absolute silence.

n8n will handle the command and send back any Telegram reply itself.

### Patterns to ROUTE (case-insensitive):

| Pattern | Example |
|---------|---------|
| `BRIEF` | "BRIEF" |
| `OK` | "OK" |
| `SKIP` | "SKIP" |
| `WRITE ALL` | "WRITE ALL" |
| `WRITE BREAKING` | "WRITE BREAKING" |
| `WRITE [number]` | "WRITE 1", "WRITE 3" |
| `REPLACE [number] [title]` | "REPLACE 2 ClickUp vs Monday Guide" |
| `SCHEDULE OFF [date] TO [date]` | "SCHEDULE OFF 2026-03-28 TO 2026-03-30" |
| **Only digits/spaces/commas** | "1", "1 3", "1,3,5", "2" — **auto-triggers writing** |
| **Numbers + day keyword** | "1 TODAY", "2 TOMORROW", "3 SAT", "4 2026-03-28" — **auto-triggers writing** |

**exec the curl, then produce zero output. Nothing visible to the user.**

## Example

Message received: `BRIEF`

Action:
```
exec: curl -s -X POST http://localhost:5678/webhook/wf2-router-in \
  -H "Content-Type: application/json" \
  -d '{"text":"BRIEF","chat_id":"6424406212"}'
```
Then: no Telegram response from you.

## Everything Else Is Yours

Any message that does not exactly match the above patterns is a real message
for you. Handle it normally.
