# AFRIPULSE Turnkey FINAL v1 — Read First

This delivery is split into multiple ZIPs so the content stays verifiable and complete.

## ZIPs
1. **AFRIPULSE_FINAL_CODE_SERVER_DB_v1.zip** — Backend + DB + WhatsApp bot (Twilio-ready) + jobs
2. **AFRIPULSE_FINAL_WEBSITE_v1.zip** — Public website + demo dashboard (EN/FR + country default language)
3. **AFRIPULSE_FINAL_GUIDES_EN_v1.zip** — Full English implementation + compliance + deployment guides
4. **AFRIPULSE_FINAL_BUSINESS_SEEDS_v1.zip** — Business docs (Word) + seeds (countries, sectors, media outlets)

## Quick start (developer)
- Install Docker + Docker Compose.
- Unzip CODE_SERVER_DB and run:
  - `docker compose up -d`
  - apply DB migrations (included) and set env files as instructed.
- Configure WhatsApp (Twilio or Meta BSP):
  - set webhook URLs, verify tokens, and environment variables.
- Open website ZIP and deploy as static site (Netlify/Vercel/Nginx).
- Point website dashboard API base to your server URL.

See the full guides in this ZIP.
