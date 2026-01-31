# AFRIPULSE — Production Deployment (English)

## Target
- Ubuntu 22.04+ VPS (2–4 vCPU, 8GB RAM to start)
- Postgres managed or local
- Nginx reverse proxy + HTTPS (Let’s Encrypt)
- Docker Compose for services

## Steps (high level)
1. Provision VPS and install:
   - docker, docker compose, git, nginx, certbot
2. Deploy server:
   - unzip CODE package
   - configure `server/.env`
   - `docker compose up -d`
3. Configure domain:
   - `api.yourdomain.com` → server
   - `afripulse.yourdomain.com` → static website
4. Set webhooks in WhatsApp provider:
   - webhook URL
   - verify token
5. Cron jobs:
   - daily aggregation
   - weekly media rankings job
   - monthly corporate report job (optional in v1)
6. Observability:
   - pm2 or docker logs
   - uptime checks
   - alerting (email/Slack)

## Security
- rotate secrets
- restrict DB exposure
- rate-limit public endpoints
- store PII separately or hashed where possible
