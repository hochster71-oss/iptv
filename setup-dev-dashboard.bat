@echo off
REM ###################################################################################
REM # IPTV Repository - Developer Dashboard Setup Script (Windows Batch)
REM # 
REM # This script automates the setup and running of a local development environment
REM # for the hochster71-oss/iptv repository.
REM #
REM # Compatible with: Windows Command Prompt
REM ###################################################################################

setlocal enabledelayedexpansion

REM Repository configuration
set REPO_URL=https://github.com/hochster71-oss/iptv.git
set REPO_NAME=iptv
set CLONE_DIR=%REPO_NAME%-dev

REM ###################################################################################
REM # Main Script
REM ###################################################################################

cls
echo.
echo ================================================================
echo        IPTV Repository - Developer Dashboard Setup
echo ================================================================
echo.

REM ###################################################################################
REM # Step 1: Check Dependencies
REM ###################################################################################

echo ========================================
echo Step 1: Checking Dependencies
echo ========================================
echo.

REM Check Git
echo [INFO] Checking for Git...
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed
    echo.
    echo Please install Git:
    echo   - Download from https://git-scm.com/download/win
    echo   - Or install via Chocolatey: choco install git
    echo   - Or install via winget: winget install Git.Git
    echo.
    goto :error
) else (
    for /f "tokens=3" %%i in ('git --version') do set GIT_VERSION=%%i
    echo [OK] Git is installed (version !GIT_VERSION!)
)

REM Check Node.js
echo [INFO] Checking for Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed
    echo.
    echo Please install Node.js (version 18.x or higher recommended):
    echo   - Download from https://nodejs.org/
    echo   - Or install via Chocolatey: choco install nodejs
    echo   - Or install via winget: winget install OpenJS.NodeJS
    echo.
    goto :error
) else (
    for /f %%i in ('node --version') do set NODE_VERSION=%%i
    echo [OK] Node.js is installed (version !NODE_VERSION!)
)

REM Check npm
echo [INFO] Checking for npm...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm is not installed
    echo.
    echo npm usually comes with Node.js. Please install Node.js.
    echo.
    goto :error
) else (
    for /f %%i in ('npm --version') do set NPM_VERSION=%%i
    echo [OK] npm is installed (version !NPM_VERSION!)
)

REM Check Python (optional)
echo [INFO] Checking for Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Python is not installed (optional)
    echo.
    echo Python is optional for this repository but recommended:
    echo   - Download from https://www.python.org/downloads/
    echo   - Or install via Chocolatey: choco install python
    echo   - Or install via winget: winget install Python.Python.3
    echo.
) else (
    for /f "tokens=2" %%i in ('python --version') do set PYTHON_VERSION=%%i
    echo [OK] Python is installed (version !PYTHON_VERSION!)
)

REM Check pip (optional)
echo [INFO] Checking for pip...
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] pip is not installed (optional)
) else (
    for /f "tokens=2" %%i in ('pip --version') do set PIP_VERSION=%%i
    echo [OK] pip is installed (version !PIP_VERSION!)
)

echo.
echo [OK] All required dependencies are installed!
echo.

REM ###################################################################################
REM # Step 2: Clone Repository
REM ###################################################################################

echo ========================================
echo Step 2: Cloning Repository
echo ========================================
echo.

REM Check if already in the repository
if exist "package.json" (
    findstr /C:"\"name\": \"iptv\"" package.json >nul
    if !errorlevel! equ 0 (
        echo [INFO] Detected that you're already in the IPTV repository!
        set /p SKIP_CLONE="Skip cloning and set up current directory? (y/n): "
        if /i "!SKIP_CLONE!"=="y" (
            goto :install_deps
        )
    )
)

REM Check if directory exists
if exist "%CLONE_DIR%" (
    echo [WARNING] Directory '%CLONE_DIR%' already exists
    set /p USE_EXISTING="Do you want to use the existing directory? (y/n): "
    if /i "!USE_EXISTING!"=="y" (
        echo [INFO] Using existing directory: %CLONE_DIR%
        goto :navigate
    ) else (
        echo [INFO] Removing existing directory...
        rmdir /s /q "%CLONE_DIR%"
    )
)

echo [INFO] Cloning repository from %REPO_URL%...
git clone %REPO_URL% %CLONE_DIR%
if %errorlevel% neq 0 (
    echo [ERROR] Failed to clone repository
    goto :error
)
echo [OK] Repository cloned successfully to '%CLONE_DIR%'
echo.

REM ###################################################################################
REM # Step 3: Navigate to Repository
REM ###################################################################################

:navigate
echo ========================================
echo Step 3: Navigating to Repository
echo ========================================
echo.

if not exist "%CLONE_DIR%" (
    echo [ERROR] Repository directory '%CLONE_DIR%' not found
    goto :error
)

cd /d "%CLONE_DIR%"
echo [OK] Navigated to %CD%
echo.

REM ###################################################################################
REM # Step 4: Install Dependencies
REM ###################################################################################

:install_deps
echo ========================================
echo Step 4: Installing npm Dependencies
echo ========================================
echo.

if not exist "package.json" (
    echo [ERROR] package.json not found in current directory
    goto :error
)

echo [INFO] Running npm install... (this may take a few minutes)
echo [WARNING] Note: Some packages may require GitHub authentication.
echo [WARNING] If you encounter errors, you may need to set up GitHub package authentication.
echo.

npm install
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies
    echo.
    echo If you see authentication errors for @iptv-org packages:
    echo 1. You may need a GitHub Personal Access Token (PAT)
    echo 2. Create .npmrc file with: //npm.pkg.github.com/:_authToken=YOUR_TOKEN
    echo 3. Or continue without authenticated packages (some features may not work)
    echo.
    set /p CONTINUE="Do you want to continue anyway? (y/n): "
    if /i not "!CONTINUE!"=="y" (
        goto :error
    )
) else (
    echo [OK] Dependencies installed successfully
)
echo.

REM ###################################################################################
REM # Step 5: Show Dashboard Info
REM ###################################################################################

echo ================================================================
echo                                                                
echo   🎉 IPTV Repository - Development Environment Setup Complete!  
echo                                                                
echo ================================================================
echo.
echo [INFO] Repository Location: %CD%
echo.
echo Available Commands:
echo.
echo   Development ^& Testing:
echo     npm run lint              - Check scripts for syntax errors
echo     npm run test              - Run all tests
echo     npm run check             - Validate playlists (lint + validate)
echo.
echo   Playlist Management:
echo     npm run playlist:format   - Format playlists
echo     npm run playlist:validate - Validate playlist data
echo     npm run playlist:test     - Test playlist streams
echo     npm run playlist:edit     - Quick stream mapping utility
echo.
echo   Data Management:
echo     npm run api:load          - Download latest channel data
echo     npm run api:generate      - Generate API JSON files
echo     npm run update            - Update playlists and documentation
echo.
echo Getting Started:
echo.
echo   1. Load the latest channel data:
echo      npm run api:load
echo.
echo   2. Validate your changes:
echo      npm run check
echo.
echo   3. Format playlists:
echo      npm run format
echo.
echo   4. Run tests:
echo      npm test
echo.
echo Documentation:
echo   - README.md         - Project overview
echo   - CONTRIBUTING.md   - Contribution guidelines
echo   - FAQ.md            - Frequently asked questions
echo.
echo Web Resources:
echo   - Channel Database: https://iptv-org.github.io/
echo   - API Documentation: https://github.com/iptv-org/api
echo   - Repository: https://github.com/hochster71-oss/iptv
echo.
echo [OK] Happy developing! 🚀
echo.
goto :end

:error
echo.
echo [ERROR] Setup failed. Please fix the errors above and try again.
pause
exit /b 1

:end
pause
exit /b 0
