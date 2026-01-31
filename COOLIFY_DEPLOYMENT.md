# AFRIPULSE - Coolify Deployment Guide

🚀 **Deploy AFRIPULSE system on your VPS using Coolify**

## Prerequisites

- VPS with Docker and Coolify installed
- Domain name pointing to your VPS
- Basic knowledge of Coolify interface

## Quick Deploy (5 Minutes)

### Step 1: Create New Project in Coolify

1. Login to your Coolify dashboard
2. Click "New Project"
3. Name: `afripulse-system`
4. Description: `AFRIPULSE Media Intelligence Platform`

### Step 2: Add Git Repository

1. Click "New Resource" → "Git Repository"
2. Repository URL: Your Git repository URL
3. Branch: `main` or `master`
4. Build Pack: `Docker Compose`

### Step 3: Configure Environment Variables

In Coolify's environment section, add these variables:

```env
# Database
POSTGRES_PASSWORD=AfriPulse2024SecureDB!
DATABASE_URL=postgres://afripulse:AfriPulse2024SecureDB!@postgres:5432/afripulse

# Security
JWT_SECRET=AfriPulse2024SuperSecretJWTKey!ChangeThis
WHATSAPP_WEBHOOK_VERIFY_TOKEN=AfriPulse2024WebhookToken!

# Domain Configuration
APP_DOMAIN=yourdomain.com
BACKEND_URL=https://api.yourdomain.com
BACKEND_PUBLIC_URL=https://api.yourdomain.com
CORS_ORIGIN=https://yourdomain.com,https://api.yourdomain.com

# WhatsApp (Optional - add when ready)
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_WHATSAPP_NUMBER=whatsapp:+1234567890

# AI Integration (Optional)
OPENAI_API_KEY=your_openai_api_key
```

### Step 4: Configure Domains

1. **Frontend Domain**: `yourdomain.com`
   - Service: `frontend`
   - Port: `3000`
   - Enable SSL: ✅

2. **Backend API Domain**: `api.yourdomain.com`
   - Service: `backend`
   - Port: `8080`
   - Enable SSL: ✅

### Step 5: Deploy

1. Click "Deploy"
2. Monitor logs for any issues
3. Wait for all services to be healthy (green status)

## Verification

### Check Services Status
- ✅ PostgreSQL: Database running
- ✅ Backend: API server responding
- ✅ Frontend: Website accessible

### Test Endpoints
- **Health Check**: `https://api.yourdomain.com/health`
- **Media API**: `https://api.yourdomain.com/public/media-shares?country=NG&category=ALL`
- **Website**: `https://yourdomain.com`
- **Dashboard**: `https://yourdomain.com/dashboard.html`

## Advanced Configuration

### Custom Database Setup

If you want to use external PostgreSQL:

```env
DATABASE_URL=postgres://username:password@external-db-host:5432/afripulse
```

### WhatsApp Integration

1. Get Twilio Account:
   - Sign up at https://twilio.com
   - Get Account SID and Auth Token
   - Purchase WhatsApp Business number

2. Configure Webhook:
   - Webhook URL: `https://api.yourdomain.com/whatsapp/webhook`
   - Verify Token: Use your `WHATSAPP_WEBHOOK_VERIFY_TOKEN`

### SSL and Security

Coolify handles SSL automatically, but ensure:
- Strong passwords for all services
- Regular security updates
- Firewall properly configured

## Scaling

### Horizontal Scaling
```yaml
# Add to docker-compose.yml
deploy:
  replicas: 3
  restart_policy:
    condition: on-failure
```

### Resource Limits
```yaml
# Add to services
resources:
  limits:
    cpus: '0.50'
    memory: 512M
  reservations:
    memory: 256M
```

## Monitoring

### Built-in Health Checks
- All services have health checks configured
- Coolify monitors service status automatically
- Automatic restarts on failure

### Logs Access
- Coolify dashboard → Your project → Logs
- Real-time log viewing
- Filter by service

### Performance Monitoring
- Database queries logged
- API response times tracked
- Error rates monitored

## Troubleshooting

### Common Issues

**502 Bad Gateway**
- Check if backend service is running
- Verify environment variables
- Check database connection

**Database Connection Failed**
```bash
# Check postgres logs in Coolify
# Verify DATABASE_URL format
# Ensure postgres service is healthy
```

**Frontend Can't Connect to API**
- Verify BACKEND_URL environment variable
- Check CORS configuration
- Ensure API domain is accessible

**WhatsApp Webhook Not Working**
- Verify webhook URL is publicly accessible
- Check WHATSAPP_WEBHOOK_VERIFY_TOKEN
- Test webhook endpoint manually

### Log Analysis

**Backend Logs:**
```bash
[AFRIPULSE] server listening on :8080
[DB] Connected to PostgreSQL
[AFRIPULSE] Environment: production
```

**Frontend Logs:**
```bash
[AFRIPULSE Website] Server running on http://0.0.0.0:3000
[AFRIPULSE Website] Backend API URL: http://backend:8080
```

**Database Logs:**
```bash
[migrate] 001_init.sql
[seed] done
```

## Backup Strategy

### Database Backup
```bash
# Coolify automatically handles volume backups
# For manual backup:
docker exec afripulse-postgres pg_dump -U afripulse afripulse > backup.sql
```

### Environment Backup
- Export environment variables from Coolify
- Store securely (encrypted)
- Document any custom configurations

## Updates and Maintenance

### Updating the Application
1. Push changes to your Git repository
2. Coolify will auto-deploy (if enabled)
3. Or manually trigger deployment

### Database Migrations
- Migrations run automatically on deployment
- Monitor logs during deployment
- Test on staging environment first

### Security Updates
- Keep base images updated
- Regular security scans
- Update dependencies

## Production Checklist

### Before Go-Live
- [ ] All environment variables configured
- [ ] Database properly initialized
- [ ] SSL certificates working
- [ ] Health checks passing
- [ ] API endpoints responding
- [ ] Frontend loading correctly
- [ ] WhatsApp integration tested
- [ ] Backup strategy in place
- [ ] Monitoring configured
- [ ] Error tracking setup

### Post-Deployment
- [ ] Monitor logs for errors
- [ ] Test all functionality
- [ ] Verify data integrity
- [ ] Performance testing
- [ ] Security scan
- [ ] User acceptance testing
- [ ] Documentation updated

## Support

### Resources
- **Coolify Docs**: https://coolify.io/docs
- **Docker Compose**: https://docs.docker.com/compose/
- **PostgreSQL**: https://www.postgresql.org/docs/

### Getting Help
1. Check Coolify logs first
2. Review this deployment guide
3. Check service health status
4. Verify environment variables
5. Test database connectivity

### Common Commands

**Restart Services:**
- Use Coolify dashboard to restart individual services

**View Logs:**
- Real-time logs available in Coolify UI

**Database Access:**
```bash
# Connect to database (from Coolify terminal)
docker exec -it afripulse-postgres psql -U afripulse -d afripulse
```

---

🎉 **Your AFRIPULSE system is now running in production!**

Access your deployment:
- **Website**: https://yourdomain.com
- **API**: https://api.yourdomain.com
- **Dashboard**: https://yourdomain.com/dashboard.html
- **Health Check**: https://api.yourdomain.com/health

For support or questions, refer to the logs and this deployment guide.