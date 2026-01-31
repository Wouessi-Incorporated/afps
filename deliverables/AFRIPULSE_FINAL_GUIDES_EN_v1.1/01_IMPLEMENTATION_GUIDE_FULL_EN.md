# AFRIPULSE — Full Implementation Guide (English)

## 1) What you are deploying
AFRIPULSE has 4 monetizable products:
1. AFRIPULSE Core (daily country pulse) — B2G/B2I
2. AFRIPULSE Media Intelligence (audience share + outlet rankings) — cash-first for advertisers
3. AFRIPULSE Market Research On-demand (72h/48h/24h/12h) — cash-first
4. AFRIPULSE Corporate Heartbeat™ (indices) + Corporate Pulse™ (reports) — premium B2B/B2G

## 2) Tech stack (v1)
- Server: Node.js (Express) + PostgreSQL
- Bot: WhatsApp webhook + state machine (Twilio-ready)
- Jobs: Node cron / server job runner
- Website: static HTML/CSS/JS (EN/FR) + demo dashboard calling public endpoints
- AI: optional LLM layer for “suggest questions” and “summaries” (kept inside allowed business use cases)

## 3) Repository structure (after unzip)
- `server/` — API + DB + jobs
- `web/` — dashboard (static)
- `docs/` — internal docs
- `env/` — example env files

## 4) Environment variables (server)
Create `server/.env` (copy from `env/server.env.example`):
- `PORT=8080`
- `DATABASE_URL=postgres://...`
- `WHATSAPP_PROVIDER=twilio|meta`
- `WHATSAPP_WEBHOOK_VERIFY_TOKEN=...`
- `TWILIO_ACCOUNT_SID=...`
- `TWILIO_AUTH_TOKEN=...`
- `TWILIO_WHATSAPP_NUMBER=whatsapp:+XXXXXXXXXXX`
- `OPENAI_API_KEY=` (optional)
- `JWT_SECRET=`

## 5) Local run (Docker)
1. `docker compose up -d`
2. Apply migrations:
   - If your image runs migrations at startup, confirm logs.
   - Otherwise run: `psql $DATABASE_URL -f server/src/db/migrations/*.sql`
3. Start server:
   - `npm install`
   - `npm run start` (or `node server/src/index.js`)

## 6) WhatsApp webhook
- Configure your provider webhook URL:
  - `https://YOUR_DOMAIN/whatsapp/webhook`
- Configure verification token:
  - `WHATSAPP_WEBHOOK_VERIFY_TOKEN`
- Test with a WhatsApp message: “hi”

## 7) Data flow (high level)
1. Respondent messages bot on WhatsApp (opt-in).
2. Bot serves micro-surveys by module and records responses.
3. Server aggregates indicators and exposes endpoints for website + clients.
4. Weekly job computes media rankings table; corporate indices are computed similarly.

## 8) Corporate Heartbeat™ (Indices) + Corporate Pulse™ (Reports)
### Core questions (minimal)
- Outlook (1–5)
- Hiring (increase/stable/decrease/uncertain)
- Revenue expectation (up/stable/down)
- Investment intention (yes/maybe/no)
- Access to finance (easy/ok/difficult/impossible)
- Constraints (top 3)
- Stress / early failure (continue/reduce/partial close/full close)

### Index method (simple v1)
Convert answers to scores and compute:
- Confidence Index (0–100)
- Hiring Expectation Index
- Investment Index
- Stress Index (higher = worse)
Aggregate weekly (rolling 7d) and monthly (calendar month).

## 9) Market Research product (paid campaigns)
Campaigns support:
- Text + single/multi-choice
- Image (link)
- Video (link)
Delivery SLAs:
- 72h standard
- 48h premium
- 24h rush
- 12h instant (highest reward boost + priority routing)

## 10) Quality & anti-fraud
- Cooldown windows to avoid survey fatigue
- Rotation to diversify respondents
- Attention checks
- Duplicate / speed / inconsistency flags
- Opt-out respected instantly

## 11) Go-live checklist
- Legal: consent/opt-in language, privacy notice, opt-out command “STOP”.
- Compliance: templates approval (for outbound), verified URLs (HTTPS).
- Operations: reward distribution pipeline tested.
- Monitoring: error alerts + message throughput limits considered.
