# AFRIPULSE Complete System - Frontend & Backend
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache python3 make g++ curl

# Copy entire project structure
COPY . ./

# Install backend dependencies
RUN cd deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server && \
    if [ -f package-lock.json ]; then \
        npm ci --only=production; \
    else \
        npm install --only=production; \
    fi && \
    npm cache clean --force

# Install frontend dependencies
RUN cd deliverables/AFRIPULSE_FINAL_WEBSITE_v1 && \
    if [ -f package-lock.json ]; then \
        npm ci --only=production; \
    else \
        npm install --only=production; \
    fi && \
    npm cache clean --force

# Set default environment variables
ENV NODE_ENV=production
ENV PORT=8080
ENV DATABASE_URL=mock
ENV JWT_SECRET=default_jwt_secret_change_in_production
ENV WHATSAPP_WEBHOOK_VERIFY_TOKEN=default_webhook_token
ENV CORS_ORIGIN=*

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

# Expose ports (frontend and backend)
EXPOSE 3000 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/health', (res) => { \
        process.exit(res.statusCode === 200 ? 0 : 1) \
    }).on('error', () => process.exit(1))" || exit 1

# Start application with start.js (runs frontend first, then backend)
CMD ["node", "start.js"]
