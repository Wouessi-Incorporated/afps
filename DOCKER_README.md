# AFRIPULSE Docker Setup Guide

🐳 **Complete Docker configuration for AFRIPULSE system deployment**

## Overview

This repository includes complete Docker support for the AFRIPULSE media intelligence platform, optimized for both local development and production deployment via Coolify.

## Quick Start

### Option 1: Automated Setup (Recommended)

**Windows:**
```cmd
docker-start.bat
```

**Linux/Mac:**
```bash
chmod +x docker-start.sh
./docker-start.sh
```

### Option 2: Manual Setup

```bash
# Create environment file
cp env.example .env

# Start services
docker compose up -d --build

# Check status
docker compose ps
```

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   PostgreSQL    │
│   (Port 3000)   │◄──►│   (Port 8080)   │◄──►│   (Port 5432)   │
│                 │    │                 │    │                 │
│ • React/HTML    │    │ • Node.js       │    │ • Database      │
│ • Multi-language│    │ • Express API   │    │ • Persistence   │
│ • Dashboard     │    │ • WhatsApp      │    │ • Migrations    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Services

### Frontend (`afripulse-frontend`)
- **Port**: 3000
- **Technology**: Node.js static server
- **Features**: Multi-language dashboard, real-time data
- **Health Check**: HTTP GET /

### Backend (`afripulse-backend`)  
- **Port**: 8080
- **Technology**: Node.js Express
- **Features**: REST API, WhatsApp integration, data aggregation
- **Health Check**: HTTP GET /health

### Database (`afripulse-postgres`)
- **Port**: 5432
- **Technology**: PostgreSQL 16
- **Features**: Persistent data storage, automatic migrations
- **Health Check**: pg_isready

## Configuration

### Environment Variables

Copy `env.example` to `.env` and customize:

```env
# Database
POSTGRES_PASSWORD=your_secure_password
DATABASE_URL=postgres://afripulse:${POSTGRES_PASSWORD}@postgres:5432/afripulse

# Security
JWT_SECRET=your_jwt_secret_key
WHATSAPP_WEBHOOK_VERIFY_TOKEN=your_webhook_token

# Deployment
APP_DOMAIN=yourdomain.com
BACKEND_URL=https://api.yourdomain.com
CORS_ORIGIN=https://yourdomain.com

# WhatsApp (Optional)
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
TWILIO_WHATSAPP_NUMBER=whatsapp:+1234567890

# AI Integration (Optional)
OPENAI_API_KEY=your_openai_key
```

### Docker Compose Services

The `docker-compose.yml` includes:

- **postgres**: Database with automatic initialization
- **backend**: API server with health checks
- **frontend**: Static file server with API injection

## Local Development

### Starting Services

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Check status
docker compose ps
```

### Accessing Services

- **Website**: http://localhost:3000
- **Dashboard**: http://localhost:3000/dashboard.html
- **API Health**: http://localhost:8080/health
- **API Data**: http://localhost:8080/public/media-shares?country=NG&category=ALL

### Development Commands

```bash
# Restart a service
docker compose restart backend

# View service logs
docker compose logs -f backend

# Execute command in container
docker exec -it afripulse-backend sh

# Access database
docker exec -it afripulse-postgres psql -U afripulse -d afripulse

# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v
```

## Production Deployment (Coolify)

### Prerequisites
- VPS with Coolify installed
- Domain name pointing to VPS
- SSL certificates (handled by Coolify)

### Deployment Steps

1. **Create Project in Coolify**
   - New Project: `afripulse-system`
   - Git Repository: Your repo URL
   - Build Pack: Docker Compose

2. **Configure Environment**
   - Copy variables from `env.example`
   - Set production values
   - Configure domains

3. **Domain Setup**
   - Frontend: `yourdomain.com` → `frontend:3000`
   - Backend: `api.yourdomain.com` → `backend:8080`
   - Enable SSL for both

4. **Deploy**
   - Click Deploy in Coolify
   - Monitor logs
   - Verify all services are healthy

### Production Environment

```env
# Production values
NODE_ENV=production
POSTGRES_PASSWORD=very_secure_production_password
JWT_SECRET=very_secure_jwt_secret_for_production
APP_DOMAIN=yourdomain.com
BACKEND_URL=https://api.yourdomain.com
CORS_ORIGIN=https://yourdomain.com,https://api.yourdomain.com
```

## Monitoring & Maintenance

### Health Checks

All services include automatic health checks:

```yaml
# Backend health check
test: ["CMD", "node", "-e", "require('http').get('http://localhost:8080/health', ...)"]
interval: 30s
timeout: 10s
retries: 3
```

### Logs

```bash
# View all logs
docker compose logs

# Follow specific service
docker compose logs -f backend

# Last 100 lines
docker compose logs --tail=100
```

### Database Backup

```bash
# Create backup
docker exec afripulse-postgres pg_dump -U afripulse afripulse > backup.sql

# Restore backup
docker exec -i afripulse-postgres psql -U afripulse -d afripulse < backup.sql
```

### Updates

```bash
# Pull latest changes
git pull

# Rebuild and restart
docker compose up -d --build

# Verify services
docker compose ps
```

## Troubleshooting

### Common Issues

**502 Bad Gateway**
```bash
# Check backend status
docker compose logs backend

# Verify database connection
docker compose logs postgres

# Check environment variables
docker compose config
```

**Database Connection Issues**
```bash
# Check PostgreSQL logs
docker compose logs postgres

# Verify DATABASE_URL format
echo $DATABASE_URL

# Test connection manually
docker exec -it afripulse-postgres psql -U afripulse -d afripulse -c "SELECT 1;"
```

**Frontend API Connection Issues**
```bash
# Check API URL injection
curl http://localhost:3000/api-config.js

# Verify backend accessibility
curl http://localhost:8080/health

# Check CORS configuration
docker compose logs backend | grep CORS
```

**Port Conflicts**
```bash
# Check what's using ports
netstat -tulpn | grep :3000
netstat -tulpn | grep :8080

# Stop conflicting services
docker compose down
```

### Service Status Check

```bash
# Quick status check
docker compose ps

# Detailed health status
docker inspect afripulse-backend --format='{{.State.Health.Status}}'
docker inspect afripulse-frontend --format='{{.State.Health.Status}}'
docker inspect afripulse-postgres --format='{{.State.Health.Status}}'
```

### Performance Monitoring

```bash
# Resource usage
docker stats

# Service-specific usage
docker stats afripulse-backend afripulse-frontend afripulse-postgres
```

## Security

### Best Practices

1. **Strong Passwords**: Use complex passwords for all services
2. **Environment Secrets**: Never commit `.env` files
3. **Regular Updates**: Keep base images updated
4. **Network Security**: Use Docker networks for isolation
5. **SSL/TLS**: Always use HTTPS in production

### Security Checklist

- [ ] Strong `POSTGRES_PASSWORD`
- [ ] Secure `JWT_SECRET`
- [ ] Unique `WHATSAPP_WEBHOOK_VERIFY_TOKEN`
- [ ] HTTPS-only in production
- [ ] Regular security updates
- [ ] Firewall configuration
- [ ] Backup encryption

## Advanced Configuration

### Custom Network

```yaml
networks:
  afripulse-network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
```

### Resource Limits

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          memory: 512M
```

### Scaling

```yaml
services:
  backend:
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
        max_attempts: 3
```

## File Structure

```
.
├── docker-compose.yml          # Main orchestration
├── .env                       # Environment variables
├── docker-start.sh            # Linux/Mac startup script
├── docker-start.bat           # Windows startup script
├── DOCKER_README.md           # This file
├── COOLIFY_DEPLOYMENT.md      # Production deployment guide
└── deliverables/
    ├── AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/
    │   ├── Dockerfile         # Backend container
    │   └── server/            # Backend source
    └── AFRIPULSE_FINAL_WEBSITE_v1/
        ├── Dockerfile         # Frontend container
        └── *.html             # Frontend files
```

## Support

### Getting Help

1. **Check Logs**: Always start with `docker compose logs`
2. **Verify Configuration**: Use `docker compose config`
3. **Test Connections**: Use health check endpoints
4. **Review Environment**: Check environment variables

### Useful Commands Reference

```bash
# Development
docker compose up -d              # Start services
docker compose down              # Stop services
docker compose logs -f           # Follow logs
docker compose ps               # Check status

# Debugging
docker exec -it afripulse-backend sh    # Backend shell
docker exec -it afripulse-postgres bash # Database shell
docker compose config                   # Verify config

# Maintenance
docker system prune             # Clean up
docker compose pull            # Update base images
docker compose build --no-cache # Force rebuild
```

---

🎉 **Your AFRIPULSE system is ready for Docker deployment!**

For production deployment on Coolify, see `COOLIFY_DEPLOYMENT.md`.
For local development, run `./docker-start.sh` or `docker-start.bat`.