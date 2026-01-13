@echo off
REM =============================================================================
REM Portable ML Lab - Quick Start Script for Windows
REM 
REM Usage:
REM   start.bat                        Use path from .env or default
REM   start.bat C:\path\to\project     Open specific project folder
REM   start.bat "C:\My Projects"       Paths with spaces need quotes
REM
REM Examples:
REM   start.bat C:\Users\john\Desktop\my-project
REM   start.bat D:\ML\experiments
REM =============================================================================

setlocal enabledelayedexpansion

set "PROJECT_PATH=%~1"
set "SCRIPT_DIR=%~dp0"

cd /d "%SCRIPT_DIR%"

REM Show help
if "%PROJECT_PATH%"=="-h" goto :showhelp
if "%PROJECT_PATH%"=="--help" goto :showhelp
if "%PROJECT_PATH%"=="/?" goto :showhelp
goto :main

:showhelp
echo Usage: start.bat [project_path]
echo.
echo Arguments:
echo   project_path    Path to your project folder (mounted as /projects)
echo.
echo Examples:
echo   start.bat C:\Users\john\Desktop\my-project
echo   start.bat D:\ML\experiments
echo.
exit /b 0

:main
REM Check Docker prerequisites
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo X Docker is not installed or not in PATH
    exit /b 1
)

docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo X Docker daemon is not running
    exit /b 1
)

REM Create .env from example if it doesn't exist
if not exist .env (
    if exist .env.example (
        copy .env.example .env >nul
        echo Created .env from .env.example
    )
)

echo ╔═══════════════════════════════════════════╗
echo ║     Portable ML Lab - Docker IDE          ║
echo ╚═══════════════════════════════════════════╝

REM Update project path if provided
if not "%PROJECT_PATH%"=="" (
    if exist "%PROJECT_PATH%" (
        echo Project path: %PROJECT_PATH%
    ) else (
        echo Directory not found: %PROJECT_PATH%
        echo Creating directory...
        mkdir "%PROJECT_PATH%"
        echo Created: %PROJECT_PATH%
    )
    REM Update .env file (convert backslashes to forward slashes)
    powershell -Command "(Get-Content .env) -replace 'HOST_PROJECTS_PATH=.*', 'HOST_PROJECTS_PATH=%PROJECT_PATH:\=/%' | Set-Content .env"
) else (
    REM Show current path from .env
    for /f "tokens=2 delims==" %%a in ('findstr "HOST_PROJECTS_PATH" .env 2^>nul') do (
        echo Project path: %%a
    )
)

REM Check if container is running
docker compose ps --status running 2>nul | findstr /C:"mlops-env" >nul
if %errorlevel%==0 (
    echo ✓ Container already running
) else (
    echo 🔨 Starting container...
    docker compose up -d
)

REM Wait for container
timeout /t 2 /nobreak >nul

REM Check if tmux session exists
docker compose exec -u dev mlops-env tmux has-session -t mlops 2>nul
if %errorlevel%==0 (
    echo ✓ Tmux session 'mlops' exists
) else (
    echo 📺 Creating tmux session...
    docker compose exec -u dev mlops-env tmuxp load -d /home/dev/.config/tmuxp/lab.yaml
)

echo.
echo ═══════════════════════════════════════════
echo ✓ Ready! Attaching to tmux session...
echo ═══════════════════════════════════════════
echo.
echo   Detach: Ctrl-a d
echo   Reattach: start.bat
echo.

REM Attach to tmux session
docker compose exec -u dev mlops-env tmux attach -t mlops
