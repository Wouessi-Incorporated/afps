# AFRIPULSE Backend API Server Dockerfile (Main for Coolify)
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Install system dependencies for building native modules
RUN apk add --no-cache python3 make g++ curl

# Copy backend package.json first (for better caching)
COPY deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package.json ./

# Copy package-lock.json if it exists, otherwise skip
COPY deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package-lock.json* ./

# Install dependencies (use npm install if no lock file, npm ci if lock file exists)
RUN if [ -f package-lock.json ]; then \
        npm ci --only=production; \
    else \
        npm install --only=production; \
    fi && \
    npm cache clean --force

# Copy all backend source code
COPY deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/ ./

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 8080

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/health', (res) => { \
        process.exit(res.statusCode === 200 ? 0 : 1) \
    }).on('error', () => process.exit(1))" || exit 1

# Start the backend server
CMD ["npm", "start"]
