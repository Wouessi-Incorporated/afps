@echo off
title AFRIPULSE System Startup
echo.
echo ========================================
echo    AFRIPULSE System - Starting...
echo ========================================
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please download and install Node.js from: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo Node.js detected. Starting system...
echo.

REM Run the startup script
node start.js

REM If we get here, the script ended (probably due to error or Ctrl+C)
echo.
echo ========================================
echo    AFRIPULSE System - Stopped
echo ========================================
echo.
pause
