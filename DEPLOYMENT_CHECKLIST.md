# AFRIPULSE Coolify Deployment Checklist

## Pre-Deployment
- [ ] Run `./prepare-deploy.sh` to fix common issues
- [ ] Commit and push all changes to Git repository
- [ ] Ensure Docker builds locally: `docker build -t afripulse-test .`

## Coolify Setup
- [ ] Create new resource in Coolify
- [ ] Select "Git Repository" → "Dockerfile" build pack
- [ ] Set repository URL and branch (usually `main`)

## Environment Variables
Copy from `env.coolify` and update:
- [ ] Set strong `POSTGRES_PASSWORD`
- [ ] Set secure `JWT_SECRET` (32+ characters)
- [ ] Set unique `WHATSAPP_WEBHOOK_VERIFY_TOKEN`
- [ ] Update `CORS_ORIGIN` with your domains
- [ ] Configure `DATABASE_URL` with your database details

## Domain Configuration
- [ ] Backend API: `api.yourdomain.com` → Port `8080`
- [ ] Enable SSL for API domain
- [ ] Test DNS resolution

## Post-Deployment Verification
- [ ] Health check: `https://api.yourdomain.com/health`
- [ ] Media API: `https://api.yourdomain.com/public/media-shares?country=NG&category=ALL`
- [ ] Check Coolify logs for errors
- [ ] Verify database connection in logs

## Troubleshooting
- 502 Bad Gateway: Check container logs in Coolify
- Database errors: Verify DATABASE_URL format
- Build failures: Check package-lock.json exists
- CORS errors: Update CORS_ORIGIN environment variable

## Security Reminders
- Use strong, unique passwords
- Never commit secrets to Git
- Enable HTTPS only
- Regular security updates
