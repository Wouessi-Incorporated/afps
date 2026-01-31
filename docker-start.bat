@echo off
setlocal EnableDelayedExpansion

title AFRIPULSE Docker Startup
echo.
echo ==========================================
echo   AFRIPULSE Docker Startup Script
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

REM Check if Docker Compose is available
docker compose version >nul 2>&1
if errorlevel 1 (
    docker-compose --version >nul 2>&1
    if errorlevel 1 (
        echo ERROR: Docker Compose is not available
        echo Please ensure Docker Desktop is running
        echo.
        pause
        exit /b 1
    )
    set COMPOSE_CMD=docker-compose
) else (
    set COMPOSE_CMD=docker compose
)

echo SUCCESS: Docker and Docker Compose are available
echo.

REM Create .env file if it doesn't exist
if not exist ".env" (
    echo WARNING: .env file not found, creating from template...
    (
        echo # AFRIPULSE Local Docker Environment
        echo POSTGRES_PASSWORD=afripulse_local_2024
        echo DATABASE_URL=postgres://afripulse:afripulse_local_2024@postgres:5432/afripulse
        echo NODE_ENV=development
        echo JWT_SECRET=afripulse_local_jwt_secret_2024
        echo WHATSAPP_WEBHOOK_VERIFY_TOKEN=local_webhook_token_2024
        echo APP_DOMAIN=localhost
        echo BACKEND_URL=http://localhost:8080
        echo BACKEND_PUBLIC_URL=http://localhost:8080
        echo CORS_ORIGIN=http://localhost:3000,http://localhost:8080
    ) > .env
    echo SUCCESS: .env file created with local development settings
    echo.
) else (
    echo SUCCESS: .env file found
    echo.
)

REM Check if ports are in use (simplified check)
echo INFO: Checking if required ports are available...
netstat -an | find "LISTENING" | find ":3000" >nul 2>&1
if not errorlevel 1 (
    echo WARNING: Port 3000 appears to be in use
    set /p STOP_EXISTING="Stop existing containers? (y/N): "
    if /i "!STOP_EXISTING!"=="y" (
        echo INFO: Stopping existing containers...
        %COMPOSE_CMD% down >nul 2>&1
    )
)

netstat -an | find "LISTENING" | find ":8080" >nul 2>&1
if not errorlevel 1 (
    echo WARNING: Port 8080 appears to be in use
)

echo.
echo INFO: Starting AFRIPULSE system with Docker...
echo.

REM Pull latest images
echo INFO: Pulling latest base images...
%COMPOSE_CMD% pull postgres >nul 2>&1

REM Build and start services
echo INFO: Building and starting services...
%COMPOSE_CMD% up -d --build

if errorlevel 1 (
    echo ERROR: Failed to start services
    echo.
    echo Showing logs:
    %COMPOSE_CMD% logs
    pause
    exit /b 1
)

REM Wait for services to be ready
echo INFO: Waiting for services to be ready...
timeout /t 15 /nobreak >nul

REM Check service health
echo INFO: Checking service health...

docker ps --format "table {{.Names}}\t{{.Status}}" | find "afripulse-postgres" | find "Up" >nul 2>&1
if errorlevel 1 (
    echo ERROR: PostgreSQL failed to start
    %COMPOSE_CMD% logs postgres
    pause
    exit /b 1
) else (
    echo SUCCESS: PostgreSQL is running
)

docker ps --format "table {{.Names}}\t{{.Status}}" | find "afripulse-backend" | find "Up" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Backend API failed to start
    %COMPOSE_CMD% logs backend
    pause
    exit /b 1
) else (
    echo SUCCESS: Backend API is running
)

docker ps --format "table {{.Names}}\t{{.Status}}" | find "afripulse-frontend" | find "Up" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Frontend website failed to start
    %COMPOSE_CMD% logs frontend
    pause
    exit /b 1
) else (
    echo SUCCESS: Frontend website is running
)

REM Test API endpoints
echo INFO: Testing API endpoints...
timeout /t 5 /nobreak >nul

REM Test health endpoint (simplified)
curl -s http://localhost:8080/health >nul 2>&1
if errorlevel 1 (
    echo WARNING: Health endpoint may not be responding yet
) else (
    echo SUCCESS: Health endpoint is responding
)

REM Test frontend
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo WARNING: Frontend website may not be accessible yet
) else (
    echo SUCCESS: Frontend website is accessible
)

echo.
echo ==========================================
echo   AFRIPULSE System is now running!
echo ==========================================
echo.
echo Frontend Website:
echo   http://localhost:3000
echo   - Homepage: http://localhost:3000/
echo   - Dashboard: http://localhost:3000/dashboard.html
echo.
echo Backend API:
echo   http://localhost:8080
echo   - Health: http://localhost:8080/health
echo   - Media: http://localhost:8080/public/media-shares?country=NG^&category=ALL
echo.
echo Database:
echo   PostgreSQL running on localhost:5432
echo   - Database: afripulse
echo   - Username: afripulse
echo   - Password: afripulse_local_2024
echo.
echo Container Status:
%COMPOSE_CMD% ps
echo.
echo Useful Commands:
echo   View logs: %COMPOSE_CMD% logs -f [service_name]
echo   Stop all:  %COMPOSE_CMD% down
echo   Restart:   %COMPOSE_CMD% restart [service_name]
echo.
echo To stop the system: %COMPOSE_CMD% down
echo.
echo Ready for Coolify deployment!
echo Follow COOLIFY_DEPLOYMENT.md for production deployment
echo.

REM Ask if user wants to open browser
set /p OPEN_BROWSER="Open http://localhost:3000 in browser? (y/N): "
if /i "!OPEN_BROWSER!"=="y" (
    start http://localhost:3000
)

echo.
echo SUCCESS: Startup complete! System is ready for use.
echo.
echo Press any key to continue or Ctrl+C to stop containers...
pause >nul
