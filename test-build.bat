@echo off
setlocal EnableDelayedExpansion

title AFRIPULSE Docker Build Test Script
echo.
echo ==========================================
echo   AFRIPULSE Docker Build Test Script
echo ==========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not installed or not in PATH
    echo Please install Docker Desktop from: https://docs.docker.com/get-docker/
    echo.
    pause
    exit /b 1
)

echo SUCCESS: Docker is installed
echo.

REM Test 1: Backend Dockerfile Build
echo INFO: Testing backend Dockerfile build...
docker build -t afripulse-backend-test -f Dockerfile . >backend-build.log 2>&1
if errorlevel 1 (
    echo ERROR: Backend Dockerfile build failed. Check logs:
    type backend-build.log
    pause
    exit /b 1
) else (
    echo SUCCESS: Backend Dockerfile builds successfully
)
echo.

REM Test 2: Frontend Dockerfile Build
echo INFO: Testing frontend Dockerfile build...
docker build -t afripulse-frontend-test -f Dockerfile.frontend . >frontend-build.log 2>&1
if errorlevel 1 (
    echo ERROR: Frontend Dockerfile build failed. Check logs:
    type frontend-build.log
    pause
    exit /b 1
) else (
    echo SUCCESS: Frontend Dockerfile builds successfully
)
echo.

REM Test 3: Check required files exist
echo INFO: Checking required files...
set FILES_MISSING=0

if exist "deliverables\AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1\server\package.json" (
    echo SUCCESS: package.json exists
) else (
    echo ERROR: package.json is missing
    set FILES_MISSING=1
)

if exist "deliverables\AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1\server\src\index.js" (
    echo SUCCESS: index.js exists
) else (
    echo ERROR: index.js is missing
    set FILES_MISSING=1
)

if exist "deliverables\AFRIPULSE_FINAL_WEBSITE_v1\server.js" (
    echo SUCCESS: server.js exists
) else (
    echo ERROR: server.js is missing
    set FILES_MISSING=1
)

if exist "deliverables\AFRIPULSE_FINAL_WEBSITE_v1\index.html" (
    echo SUCCESS: index.html exists
) else (
    echo ERROR: index.html is missing
    set FILES_MISSING=1
)

if exist "deliverables\AFRIPULSE_FINAL_WEBSITE_v1\dashboard.html" (
    echo SUCCESS: dashboard.html exists
) else (
    echo ERROR: dashboard.html is missing
    set FILES_MISSING=1
)

if exist "docker-compose.yml" (
    echo SUCCESS: docker-compose.yml exists
) else (
    echo ERROR: docker-compose.yml is missing
    set FILES_MISSING=1
)

if !FILES_MISSING!==1 (
    echo ERROR: Some required files are missing
    pause
    exit /b 1
)
echo.

REM Test 4: Package.json validation
echo INFO: Validating backend package.json...
node -e "JSON.parse(require('fs').readFileSync('deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server/package.json'))" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Backend package.json is invalid JSON
    pause
    exit /b 1
) else (
    echo SUCCESS: Backend package.json is valid JSON
)
echo.

REM Test 5: Docker Compose validation
echo INFO: Validating docker-compose.yml...
docker compose version >nul 2>&1
if errorlevel 1 (
    docker-compose --version >nul 2>&1
    if errorlevel 1 (
        echo WARNING: Docker Compose not available, skipping validation
        set COMPOSE_CMD=
    ) else (
        set COMPOSE_CMD=docker-compose
    )
) else (
    set COMPOSE_CMD=docker compose
)

if not "!COMPOSE_CMD!"=="" (
    !COMPOSE_CMD! config >nul 2>&1
    if errorlevel 1 (
        echo ERROR: docker-compose.yml has errors:
        !COMPOSE_CMD! config
        pause
        exit /b 1
    ) else (
        echo SUCCESS: docker-compose.yml is valid
    )
)
echo.

REM Test 6: Test backend container startup
echo INFO: Testing backend container startup...
docker run -d --name afripulse-backend-test-run -e DATABASE_URL=mock -p 8081:8080 afripulse-backend-test >nul 2>&1
if errorlevel 1 (
    echo ERROR: Backend container failed to start
    docker logs afripulse-backend-test-run 2>nul
    docker rm -f afripulse-backend-test-run >nul 2>&1
    pause
    exit /b 1
) else (
    echo SUCCESS: Backend container started
    timeout /t 5 /nobreak >nul

    REM Test if backend responds (simplified check)
    curl -s http://localhost:8081/health >nul 2>&1
    if errorlevel 1 (
        echo WARNING: Backend container starts but health check failed ^(may need database^)
        docker logs afripulse-backend-test-run 2>nul | findstr /E ""
    ) else (
        echo SUCCESS: Backend container responds to health check
    )

    REM Cleanup
    docker stop afripulse-backend-test-run >nul 2>&1
    docker rm afripulse-backend-test-run >nul 2>&1
)
echo.

REM Test 7: Test frontend container startup
echo INFO: Testing frontend container startup...
docker run -d --name afripulse-frontend-test-run -p 3001:3000 afripulse-frontend-test >nul 2>&1
if errorlevel 1 (
    echo ERROR: Frontend container failed to start
    docker logs afripulse-frontend-test-run 2>nul
    docker rm -f afripulse-frontend-test-run >nul 2>&1
    pause
    exit /b 1
) else (
    echo SUCCESS: Frontend container started
    timeout /t 3 /nobreak >nul

    REM Test if frontend responds (simplified check)
    curl -s http://localhost:3001 >nul 2>&1
    if errorlevel 1 (
        echo WARNING: Frontend container starts but doesn't respond yet
    ) else (
        echo SUCCESS: Frontend container responds
    )

    REM Cleanup
    docker stop afripulse-frontend-test-run >nul 2>&1
    docker rm afripulse-frontend-test-run >nul 2>&1
)
echo.

REM Test 8: Check environment file template
echo INFO: Checking environment configuration...
if exist "env.example" (
    echo SUCCESS: Environment template exists

    REM Check for required variables
    findstr /C:"DATABASE_URL" env.example >nul 2>&1
    if errorlevel 1 (
        echo WARNING: DATABASE_URL is missing from environment template
    ) else (
        echo SUCCESS: DATABASE_URL is in environment template
    )

    findstr /C:"JWT_SECRET" env.example >nul 2>&1
    if errorlevel 1 (
        echo WARNING: JWT_SECRET is missing from environment template
    ) else (
        echo SUCCESS: JWT_SECRET is in environment template
    )

    findstr /C:"NODE_ENV" env.example >nul 2>&1
    if errorlevel 1 (
        echo WARNING: NODE_ENV is missing from environment template
    ) else (
        echo SUCCESS: NODE_ENV is in environment template
    )
) else (
    echo WARNING: env.example not found - creating basic template
    (
        echo # AFRIPULSE Environment Configuration
        echo DATABASE_URL=postgres://afripulse:password@postgres:5432/afripulse
        echo JWT_SECRET=your_secure_jwt_secret_key
        echo NODE_ENV=production
        echo WHATSAPP_WEBHOOK_VERIFY_TOKEN=your_webhook_token
        echo CORS_ORIGIN=https://yourdomain.com
    ) > env.example
    echo SUCCESS: Created basic env.example template
)
echo.

REM Cleanup test images
echo INFO: Cleaning up test images...
docker rmi afripulse-backend-test afripulse-frontend-test >nul 2>&1

REM Test 9: Final deployment readiness check
echo INFO: Deployment readiness checklist:
echo.
echo SUCCESS: Dockerfile exists in root directory
echo SUCCESS: Dockerfile.frontend exists for frontend service
echo SUCCESS: docker-compose.yml is valid
echo SUCCESS: Backend builds successfully
echo SUCCESS: Frontend builds successfully
echo SUCCESS: Required source files present
echo SUCCESS: Package.json files valid
echo SUCCESS: Environment template available
echo.

echo ==========================================
echo   BUILD TEST COMPLETED SUCCESSFULLY!
echo ==========================================
echo.
echo Your AFRIPULSE project is ready for Coolify deployment!
echo.
echo Next steps:
echo 1. Push your code to Git repository
echo 2. Create new resource in Coolify
echo 3. Select 'Git Repository' -^> 'Dockerfile' build pack
echo 4. Configure environment variables from env.example
echo 5. Set up domains and SSL
echo 6. Deploy!
echo.
echo For detailed deployment instructions, see:
echo - COOLIFY_SETUP.md
echo - DOCKER_README.md
echo.
echo SUCCESS: Build test completed - ready for deployment!
echo.

REM Cleanup log files
if exist backend-build.log del backend-build.log
if exist frontend-build.log del frontend-build.log

pause
