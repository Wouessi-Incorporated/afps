# AFRIPULSE Coolify Deployment Guide

🚀 **Complete guide to deploy AFRIPULSE on your VPS using Coolify**

## Problem Solved ✅

The "Dockerfile not found" error occurs because Coolify expects a Dockerfile in the root directory. This guide provides the correct setup for Coolify deployment.

## Architecture Overview

```
AFRIPULSE System on Coolify:
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   PostgreSQL    │
│   Service 1     │◄──►│    Service 2    │◄──►│   Service 3     │
│   Port 3000     │    │    Port 8080    │    │   Port 5432     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Quick Deploy (Method 1: Separate Services - Recommended)

### Step 1: Create PostgreSQL Database Service

1. **In Coolify Dashboard:**
   - Click "New Resource" → "Database" → "PostgreSQL"
   - Name: `afripulse-postgres`
   - Database: `afripulse`
   - Username: `afripulse`  
   - Password: `AfriPulse2024SecureDB!`
   - **Save the connection details!**

### Step 2: Deploy Backend API Service

1. **Create New Resource:**
   - Click "New Resource" → "Git Repository"
   - Repository URL: `your-git-repo-url`
   - Branch: `main`
   - Build Pack: `Dockerfile`
   - Dockerfile Path: `Dockerfile` (default)

2. **Environment Variables:**
```env
NODE_ENV=production
PORT=8080
DATABASE_URL=postgres://afripulse:AfriPulse2024SecureDB!@afripulse-postgres:5432/afripulse
JWT_SECRET=AfriPulse2024SuperSecretJWTKey!ChangeThis
WHATSAPP_WEBHOOK_VERIFY_TOKEN=AfriPulse2024WebhookToken!
CORS_ORIGIN=https://yourdomain.com,https://api.yourdomain.com
```

3. **Domain Configuration:**
   - Domain: `api.yourdomain.com`
   - Port: `8080`
   - Enable SSL: ✅

4. **Deploy Backend**

### Step 3: Deploy Frontend Website Service

1. **Create New Resource:**
   - Click "New Resource" → "Git Repository"  
   - Repository URL: `your-git-repo-url`
   - Branch: `main`
   - Build Pack: `Dockerfile`
   - Dockerfile Path: `Dockerfile.frontend`

2. **Environment Variables:**
```env
NODE_ENV=production
PORT=3000
BACKEND_URL=https://api.yourdomain.com
BACKEND_PUBLIC_URL=https://api.yourdomain.com
AFRIPULSE_API_URL=https://api.yourdomain.com
```

3. **Domain Configuration:**
   - Domain: `yourdomain.com`
   - Port: `3000`
   - Enable SSL: ✅

4. **Deploy Frontend**

## Alternative Deploy (Method 2: Single Service with Database)

If you prefer to use docker-compose with the database:

### Step 1: Create New Project

1. **In Coolify:**
   - Click "New Resource" → "Git Repository"
   - Repository URL: `your-git-repo-url`
   - Branch: `main`
   - Build Pack: `Docker Compose`

### Step 2: Configure Environment Variables

```env
# Database
POSTGRES_PASSWORD=AfriPulse2024SecureDB!
DATABASE_URL=postgres://afripulse:AfriPulse2024SecureDB!@postgres:5432/afripulse

# Security
NODE_ENV=production
JWT_SECRET=AfriPulse2024SuperSecretJWTKey!ChangeThis
WHATSAPP_WEBHOOK_VERIFY_TOKEN=AfriPulse2024WebhookToken!

# Domains
BACKEND_URL=https://api.yourdomain.com
BACKEND_PUBLIC_URL=https://api.yourdomain.com
CORS_ORIGIN=https://yourdomain.com,https://api.yourdomain.com

# WhatsApp Integration (Optional)
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_WHATSAPP_NUMBER=whatsapp:+1234567890

# AI Integration (Optional)
OPENAI_API_KEY=your_openai_api_key
```

### Step 3: Configure Domain

- Domain: `api.yourdomain.com`
- Port: `8080`
- Enable SSL: ✅

### Step 4: Deploy

Click "Deploy" and monitor logs.

## File Structure Requirements

Your repository MUST have these files in the root:

```
your-repo/
├── Dockerfile                    # Backend service (main)
├── Dockerfile.frontend          # Frontend service
├── docker-compose.yml          # For docker-compose deployments
├── deliverables/
│   ├── AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/
│   │   └── server/
│   │       ├── package.json
│   │       └── src/
│   └── AFRIPULSE_FINAL_WEBSITE_v1/
│       ├── server.js
│       ├── index.html
│       └── dashboard.html
```

## Environment Variables Reference

### Required Variables
```env
DATABASE_URL=postgres://username:password@host:port/database
JWT_SECRET=your_very_secure_jwt_secret_key
NODE_ENV=production
```

### Optional Variables
```env
# WhatsApp Integration
WHATSAPP_PROVIDER=twilio
TWILIO_ACCOUNT_SID=your_sid
TWILIO_AUTH_TOKEN=your_token
TWILIO_WHATSAPP_NUMBER=whatsapp:+1234567890
WHATSAPP_WEBHOOK_VERIFY_TOKEN=your_webhook_token

# AI Features
OPENAI_API_KEY=your_openai_key

# Frontend Configuration
BACKEND_URL=https://api.yourdomain.com
BACKEND_PUBLIC_URL=https://api.yourdomain.com
CORS_ORIGIN=https://yourdomain.com
```

## Security Configuration

### 1. Strong Passwords
- Use complex passwords for all services
- Never use default values in production

### 2. Environment Secrets
```env
# Generate secure secrets:
JWT_SECRET=$(openssl rand -base64 32)
POSTGRES_PASSWORD=$(openssl rand -base64 24)
WHATSAPP_WEBHOOK_VERIFY_TOKEN=$(openssl rand -base64 16)
```

### 3. CORS Setup
```env
CORS_ORIGIN=https://yourdomain.com,https://api.yourdomain.com,https://www.yourdomain.com
```

## Verification Steps

### 1. Check Service Health

**Backend API:**
- URL: `https://api.yourdomain.com/health`
- Expected: `{"ok":true,"ts":"2024-XX-XXTXX:XX:XX.XXXZ"}`

**Media Shares API:**
- URL: `https://api.yourdomain.com/public/media-shares?country=NG&category=ALL`
- Expected: JSON with media data

**Frontend Website:**
- URL: `https://yourdomain.com`
- Expected: AFRIPULSE homepage loads

**Dashboard:**
- URL: `https://yourdomain.com/dashboard.html`  
- Expected: Dashboard with live data from API

### 2. Database Connection Test

In Coolify logs, look for:
```
[AFRIPULSE] Database initialization completed
[DB] Connected to PostgreSQL
```

### 3. API Integration Test

Dashboard should show:
- Live media share data
- Country/category filtering working
- No CORS errors in browser console

## Troubleshooting

### "Dockerfile not found" Error
**Solution:** Ensure `Dockerfile` exists in repository root (done ✅)

### "502 Bad Gateway" Error
**Causes & Solutions:**
1. **Backend not running:** Check Coolify logs for backend service
2. **Database connection failed:** Verify DATABASE_URL format
3. **Port mismatch:** Ensure service runs on configured port
4. **Health check failing:** Check health endpoint responds

### Database Connection Issues
```bash
# Check logs in Coolify
# Look for:
[ERROR] Database initialization failed
[ERROR] Connection refused

# Solution: Verify DATABASE_URL format:
postgres://username:password@hostname:5432/database_name
```

### CORS Issues
```bash
# Browser console shows CORS errors
# Solution: Update CORS_ORIGIN environment variable
CORS_ORIGIN=https://yourdomain.com,https://api.yourdomain.com
```

### Frontend Can't Connect to API
```bash
# Check network tab in browser dev tools
# Look for failed API requests

# Solution 1: Verify BACKEND_URL environment variable
BACKEND_URL=https://api.yourdomain.com

# Solution 2: Check if API domain is accessible
curl https://api.yourdomain.com/health
```

## Post-Deployment Checklist

### Immediate Verification
- [ ] Backend health endpoint responds (200 OK)
- [ ] Database connection established
- [ ] Frontend website loads
- [ ] Dashboard shows live data
- [ ] API endpoints return correct data
- [ ] SSL certificates active for both domains

### Functional Testing
- [ ] Media shares API with different countries
- [ ] Dashboard filtering (TV, Radio, Online, Social)
- [ ] Multi-language switching (EN/FR)
- [ ] WhatsApp webhook (if configured)
- [ ] Error handling (404, 500 pages)

### Security Verification
- [ ] HTTPS enforced on all endpoints
- [ ] Environment variables not exposed
- [ ] Database credentials secure
- [ ] CORS properly configured
- [ ] Health checks working

## Production Optimization

### Performance
```env
# Add to environment for better performance
NODE_OPTIONS=--max-old-space-size=2048
```

### Monitoring
- Enable Coolify health checks
- Monitor application logs regularly
- Set up error alerting

### Backup Strategy
- Database: Coolify handles automatic backups
- Code: Git repository serves as backup
- Environment: Export and store securely

## Scaling

### Vertical Scaling (More Resources)
- Increase CPU/Memory limits in Coolify
- Monitor resource usage

### Horizontal Scaling (Multiple Instances)
- Deploy multiple backend instances
- Use load balancer (Coolify handles this)

## Support

### Common Commands
```bash
# View logs in Coolify dashboard
# Restart services from Coolify interface
# Update environment variables in Coolify
```

### Getting Help
1. Check Coolify service logs first
2. Verify environment variables
3. Test API endpoints manually
4. Check database connectivity
5. Review this deployment guide

---

## Success! 🎉

After deployment, your AFRIPULSE system will be available at:

- **Website**: https://yourdomain.com
- **Dashboard**: https://yourdomain.com/dashboard.html
- **API Health**: https://api.yourdomain.com/health  
- **API Data**: https://api.yourdomain.com/public/media-shares?country=NG&category=ALL

The system is now production-ready and will automatically:
- Handle SSL certificates
- Restart on failures
- Scale with load
- Backup data
- Monitor health

**Your AFRIPULSE media intelligence platform is live!**