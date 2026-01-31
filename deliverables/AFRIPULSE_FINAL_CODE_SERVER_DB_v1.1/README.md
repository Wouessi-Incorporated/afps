# AFRIPULSE — CODE + SERVER + DB (v1.1)

## Quick start (local)
1. Install Docker + Docker Compose
2. Run:
   - `docker compose up -d`
3. Test:
   - `GET http://localhost:8080/health`
   - `GET http://localhost:8080/public/media-shares?country=NG&category=ALL`

## WhatsApp webhook
- POST: `/whatsapp/webhook`
- Opt-out: `STOP`
- Survey flow (demo):
  1) user sends category (TV/RADIO/ONLINE/SOCIAL)
  2) user sends outlet name
  3) stored + aggregated

## Notes
This is a **working minimal** build designed to be extended quickly (DRSM quotas, rewards, corporate modules).
