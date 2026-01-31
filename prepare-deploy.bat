@echo off
setlocal EnableDelayedExpansion

title AFRIPULSE Deployment Preparation Script
echo.
echo ==========================================
echo   AFRIPULSE Deployment Preparation Script
echo ==========================================
echo.

REM Check if we're in the right directory
if not exist "docker-compose.yml" (
    echo ERROR: docker-compose.yml not found
    echo Please run this script from the AFRIPULSE project root directory
    pause
    exit /b 1
)

if not exist "deliverables" (
    echo ERROR: deliverables directory not found
    echo Please run this script from the AFRIPULSE project root directory
    pause
    exit /b 1
)

echo SUCCESS: Found project root directory
echo.

REM Step 1: Fix package-lock.json issue
echo INFO: Step 1: Ensuring package-lock.json exists...
set SERVER_DIR=deliverables\AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1\server

if not exist "%SERVER_DIR%\package-lock.json" (
    echo WARNING: package-lock.json not found. Generating...

    npm --version >nul 2>&1
    if errorlevel 1 (
        echo WARNING: npm not found. Creating minimal package-lock.json
        (
            echo {
            echo   "name": "afripulse-server",
            echo   "version": "1.0.0",
            echo   "lockfileVersion": 3,
            echo   "requires": true,
            echo   "packages": {
            echo     "": {
            echo       "name": "afripulse-server",
            echo       "version": "1.0.0",
            echo       "dependencies": {
            echo         "cors": "^2.8.5",
            echo         "dotenv": "^16.4.5",
            echo         "express": "^4.19.2",
            echo         "helmet": "^7.1.0",
            echo         "morgan": "^1.10.0",
            echo         "pg": "^8.12.0",
            echo         "zod": "^3.23.8"
            echo       }
            echo     }
            echo   }
            echo }
        ) > "%SERVER_DIR%\package-lock.json"
    ) else (
        cd "%SERVER_DIR%"
        npm install --package-lock-only
        cd ..\..\..
    )
    echo SUCCESS: Generated package-lock.json
) else (
    echo SUCCESS: package-lock.json already exists
)
echo.

REM Step 2: Create optimized Dockerfile
echo INFO: Step 2: Creating optimized Dockerfile...
(
echo # AFRIPULSE Backend API Server - Optimized for Coolify
echo FROM node:20-alpine
echo.
echo # Set working directory
echo WORKDIR /app
echo.
echo # Install system dependencies
echo RUN apk add --no-cache python3 make g++ curl
echo.
echo # Copy package files
echo COPY deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package.json ./
echo COPY deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package-lock.json* ./
echo.
echo # Install dependencies based on available files
echo RUN if [ -f package-lock.json ]; then \
echo         echo "Using npm ci with package-lock.json" ^&^& \
echo         npm ci --only=production; \
echo     else \
echo         echo "Using npm install ^(no package-lock.json found^)" ^&^& \
echo         npm install --only=production; \
echo     fi ^&^& \
echo     npm cache clean --force
echo.
echo # Copy source code
echo COPY deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/ ./
echo.
echo # Create non-root user
echo RUN addgroup -g 1001 -S nodejs ^&^& \
echo     adduser -S nodejs -u 1001 ^&^& \
echo     chown -R nodejs:nodejs /app
echo.
echo USER nodejs
echo.
echo # Expose port
echo EXPOSE 8080
echo.
echo # Health check
echo HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
echo     CMD node -e "require('http'^).get('http://localhost:8080/health', ^(res^) =^> { \
echo         process.exit^(res.statusCode === 200 ? 0 : 1^) \
echo     }^).on('error', ^(^) =^> process.exit^(1^)^)" ^|^| exit 1
echo.
echo # Start application
echo CMD ["npm", "start"]
) > Dockerfile

echo SUCCESS: Created optimized Dockerfile
echo.

REM Step 3: Create .dockerignore
echo INFO: Step 3: Creating .dockerignore for faster builds...
(
echo # Node.js
echo node_modules
echo npm-debug.log*
echo yarn-debug.log*
echo .npm
echo.
echo # Version control
echo .git
echo .gitignore
echo.
echo # Environment files
echo .env*
echo.
echo # Documentation
echo *.md
echo !README.md
echo.
echo # IDE files
echo .vscode/
echo .idea/
echo *.swp
echo.
echo # OS files
echo .DS_Store
echo Thumbs.db
echo.
echo # Logs
echo logs
echo *.log
echo.
echo # Temporary files
echo tmp/
echo temp/
echo.
echo # Test files
echo test/
echo tests/
echo *.test.js
echo *.spec.js
echo.
echo # Build artifacts
echo build/
echo dist/
echo.
echo # Development scripts
echo docker-start.*
echo test-build.*
echo prepare-deploy.sh
echo prepare-deploy.bat
echo.
echo # Deployment configs
echo nginx/
echo ssl/
echo monitoring/
) > .dockerignore

echo SUCCESS: Created .dockerignore
echo.

REM Step 4: Create environment template
echo INFO: Step 4: Creating environment template...
(
echo # AFRIPULSE Environment Variables for Coolify
echo # Copy these to your Coolify environment configuration
echo.
echo # Core Application Settings
echo NODE_ENV=production
echo PORT=8080
echo.
echo # Database Configuration
echo POSTGRES_PASSWORD=REPLACE_WITH_SECURE_PASSWORD
echo DATABASE_URL=postgres://afripulse:REPLACE_WITH_SECURE_PASSWORD@YOUR_DB_HOST:5432/afripulse
echo.
echo # Security Settings
echo JWT_SECRET=REPLACE_WITH_SECURE_JWT_SECRET_32_CHARS_MIN
echo WHATSAPP_WEBHOOK_VERIFY_TOKEN=REPLACE_WITH_WEBHOOK_TOKEN
echo.
echo # CORS Configuration ^(replace with your actual domains^)
echo CORS_ORIGIN=https://yourdomain.com,https://api.yourdomain.com
echo.
echo # WhatsApp Integration ^(Optional - configure when ready^)
echo WHATSAPP_PROVIDER=twilio
echo TWILIO_ACCOUNT_SID=your_twilio_account_sid
echo TWILIO_AUTH_TOKEN=your_twilio_auth_token
echo TWILIO_WHATSAPP_NUMBER=whatsapp:+1234567890
echo.
echo # AI Integration ^(Optional^)
echo OPENAI_API_KEY=your_openai_api_key
echo.
echo # Frontend URLs ^(for API injection^)
echo BACKEND_URL=https://api.yourdomain.com
echo BACKEND_PUBLIC_URL=https://api.yourdomain.com
echo.
echo # How to generate secure secrets:
echo # JWT_SECRET: openssl rand -base64 32
echo # POSTGRES_PASSWORD: openssl rand -base64 24
echo # WHATSAPP_WEBHOOK_VERIFY_TOKEN: openssl rand -base64 16
) > env.coolify

echo SUCCESS: Created env.coolify template
echo.

REM Step 5: Create deployment checklist
echo INFO: Step 5: Creating deployment checklist...
(
echo # AFRIPULSE Coolify Deployment Checklist
echo.
echo ## Pre-Deployment
echo - [ ] Run `prepare-deploy.bat` to fix common issues
echo - [ ] Commit and push all changes to Git repository
echo - [ ] Ensure Docker builds locally: `docker build -t afripulse-test .`
echo.
echo ## Coolify Setup
echo - [ ] Create new resource in Coolify
echo - [ ] Select "Git Repository" -^> "Dockerfile" build pack
echo - [ ] Set repository URL and branch ^(usually `main`^)
echo.
echo ## Environment Variables
echo Copy from `env.coolify` and update:
echo - [ ] Set strong `POSTGRES_PASSWORD`
echo - [ ] Set secure `JWT_SECRET` ^(32+ characters^)
echo - [ ] Set unique `WHATSAPP_WEBHOOK_VERIFY_TOKEN`
echo - [ ] Update `CORS_ORIGIN` with your domains
echo - [ ] Configure `DATABASE_URL` with your database details
echo.
echo ## Domain Configuration
echo - [ ] Backend API: `api.yourdomain.com` -^> Port `8080`
echo - [ ] Enable SSL for API domain
echo - [ ] Test DNS resolution
echo.
echo ## Post-Deployment Verification
echo - [ ] Health check: `https://api.yourdomain.com/health`
echo - [ ] Media API: `https://api.yourdomain.com/public/media-shares?country=NG^&category=ALL`
echo - [ ] Check Coolify logs for errors
echo - [ ] Verify database connection in logs
echo.
echo ## Troubleshooting
echo - 502 Bad Gateway: Check container logs in Coolify
echo - Database errors: Verify DATABASE_URL format
echo - Build failures: Check package-lock.json exists
echo - CORS errors: Update CORS_ORIGIN environment variable
echo.
echo ## Security Reminders
echo - Use strong, unique passwords
echo - Never commit secrets to Git
echo - Enable HTTPS only
echo - Regular security updates
) > DEPLOYMENT_CHECKLIST.md

echo SUCCESS: Created deployment checklist
echo.

REM Step 6: Test Docker build
echo INFO: Step 6: Testing Docker build locally...
docker --version >nul 2>&1
if errorlevel 1 (
    echo WARNING: Docker not found - skipping build test
) else (
    docker build -t afripulse-deploy-test . >build.log 2>&1
    if errorlevel 1 (
        echo ERROR: Docker build failed. Check build.log for details:
        type build.log | findstr /E ""
        pause
        exit /b 1
    ) else (
        echo SUCCESS: Docker build successful!
        docker rmi afripulse-deploy-test >nul 2>&1
    )
)
echo.

REM Step 7: Final validation
echo INFO: Step 7: Final validation...
set VALIDATION_FAILED=0

REM Check required files
if exist "Dockerfile" (
    echo SUCCESS: Dockerfile exists
) else (
    echo ERROR: Dockerfile missing
    set VALIDATION_FAILED=1
)

if exist ".dockerignore" (
    echo SUCCESS: .dockerignore exists
) else (
    echo ERROR: .dockerignore missing
    set VALIDATION_FAILED=1
)

if exist "docker-compose.yml" (
    echo SUCCESS: docker-compose.yml exists
) else (
    echo ERROR: docker-compose.yml missing
    set VALIDATION_FAILED=1
)

if exist "%SERVER_DIR%\package.json" (
    echo SUCCESS: package.json exists
) else (
    echo ERROR: package.json missing
    set VALIDATION_FAILED=1
)

if exist "%SERVER_DIR%\package-lock.json" (
    echo SUCCESS: package-lock.json exists
) else (
    echo ERROR: package-lock.json missing
    set VALIDATION_FAILED=1
)

if exist "%SERVER_DIR%\src\index.js" (
    echo SUCCESS: index.js exists
) else (
    echo ERROR: index.js missing
    set VALIDATION_FAILED=1
)

if exist "deliverables\AFRIPULSE_FINAL_WEBSITE_v1\server.js" (
    echo SUCCESS: server.js exists
) else (
    echo ERROR: server.js missing
    set VALIDATION_FAILED=1
)

if exist "deliverables\AFRIPULSE_FINAL_WEBSITE_v1\index.html" (
    echo SUCCESS: index.html exists
) else (
    echo ERROR: index.html missing
    set VALIDATION_FAILED=1
)

if exist "deliverables\AFRIPULSE_FINAL_WEBSITE_v1\dashboard.html" (
    echo SUCCESS: dashboard.html exists
) else (
    echo ERROR: dashboard.html missing
    set VALIDATION_FAILED=1
)

echo.

REM Cleanup
if exist build.log del build.log

if !VALIDATION_FAILED!==0 (
    echo ==========================================
    echo   DEPLOYMENT PREPARATION COMPLETED!
    echo ==========================================
    echo.
    echo Your AFRIPULSE project is ready for Coolify deployment!
    echo.
    echo Next steps:
    echo 1. Commit and push changes to Git:
    echo    git add .
    echo    git commit -m "Prepare for Coolify deployment"
    echo    git push origin main
    echo.
    echo 2. In Coolify:
    echo    - Create new resource -^> Git Repository
    echo    - Build pack: Dockerfile
    echo    - Copy environment variables from env.coolify
    echo    - Set domain: api.yourdomain.com -^> port 8080
    echo.
    echo 3. Follow DEPLOYMENT_CHECKLIST.md for detailed steps
    echo.
    echo SUCCESS: Ready for deployment!
) else (
    echo ERROR: Some files are missing. Please fix the issues above.
    pause
    exit /b 1
)

echo.
pause
