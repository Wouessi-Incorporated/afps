# AFRIPULSE Backend API Server - Optimized for Coolify
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache python3 make g++ curl

# Copy package files
COPY deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package.json ./
COPY deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package-lock.json* ./

# Install dependencies based on available files
RUN if [ -f package-lock.json ]; then \
        echo "Using npm ci with package-lock.json" && \
        npm ci --only=production; \
    else \
        echo "Using npm install (no package-lock.json found)" && \
        npm install --only=production; \
    fi && \
    npm cache clean --force

# Copy source code
COPY deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/ ./

# Set default environment variables (will be overridden by Coolify)
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

# Expose port
EXPOSE 8080

# Health check
# Health check for container orchestration (dynamic port)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD node -e "const port = process.env.PORT || 8080; require('http').get('http://localhost:' + port + '/health', (res) => { \
        process.exit(res.statusCode === 200 ? 0 : 1) \
    }).on('error', () => process.exit(1))" || exit 1

# Start application with regular npm start
CMD ["npm", "start"]
