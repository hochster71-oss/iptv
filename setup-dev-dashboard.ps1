###################################################################################
# IPTV Repository - Developer Dashboard Setup Script (Windows PowerShell)
# 
# This script automates the setup and running of a local development environment
# for the hochster71-oss/iptv repository.
#
# Compatible with: Windows PowerShell 5.1+ and PowerShell Core 7+
###################################################################################

# Set error action preference
$ErrorActionPreference = "Stop"

# Repository configuration
$REPO_URL = "https://github.com/hochster71-oss/iptv.git"
$REPO_NAME = "iptv"
$CLONE_DIR = "$REPO_NAME-dev"

###################################################################################
# Helper Functions
###################################################################################

function Print-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host $Message -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host ""
}

function Print-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Print-Error {
    param([string]$Message)
    Write-Host "✗ Error: $Message" -ForegroundColor Red
}

function Print-Warning {
    param([string]$Message)
    Write-Host "⚠ Warning: $Message" -ForegroundColor Yellow
}

function Print-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

###################################################################################
# Dependency Checking Functions
###################################################################################

function Check-Git {
    Print-Info "Checking for Git..."
    try {
        $gitVersion = (git --version 2>&1) -replace 'git version ', ''
        Print-Success "Git is installed (version $gitVersion)"
        return $true
    }
    catch {
        Print-Error "Git is not installed"
        Write-Host ""
        Write-Host "Please install Git:"
        Write-Host "  - Download from https://git-scm.com/download/win"
        Write-Host "  - Or install via Chocolatey: choco install git"
        Write-Host "  - Or install via winget: winget install Git.Git"
        Write-Host ""
        return $false
    }
}

function Check-Node {
    Print-Info "Checking for Node.js..."
    try {
        $nodeVersion = node --version 2>&1
        Print-Success "Node.js is installed (version $nodeVersion)"
        return $true
    }
    catch {
        Print-Error "Node.js is not installed"
        Write-Host ""
        Write-Host "Please install Node.js (version 18.x or higher recommended):"
        Write-Host "  - Download from https://nodejs.org/"
        Write-Host "  - Or install via Chocolatey: choco install nodejs"
        Write-Host "  - Or install via winget: winget install OpenJS.NodeJS"
        Write-Host ""
        return $false
    }
}

function Check-Npm {
    Print-Info "Checking for npm..."
    try {
        $npmVersion = npm --version 2>&1
        Print-Success "npm is installed (version $npmVersion)"
        return $true
    }
    catch {
        Print-Error "npm is not installed"
        Write-Host ""
        Write-Host "npm usually comes with Node.js. Please install Node.js."
        Write-Host ""
        return $false
    }
}

function Check-Python {
    Print-Info "Checking for Python..."
    
    # Try python3 first, then python
    try {
        $pythonVersion = (python --version 2>&1) -replace 'Python ', ''
        Print-Success "Python is installed (version $pythonVersion)"
        return $true
    }
    catch {
        Print-Warning "Python is not installed"
        Write-Host ""
        Write-Host "Python is optional for this repository but recommended:"
        Write-Host "  - Download from https://www.python.org/downloads/"
        Write-Host "  - Or install via Chocolatey: choco install python"
        Write-Host "  - Or install via winget: winget install Python.Python.3"
        Write-Host ""
        return $true  # Return true since Python is optional
    }
}

function Check-Pip {
    Print-Info "Checking for pip..."
    
    try {
        $pipVersion = (pip --version 2>&1) -split ' ' | Select-Object -Index 1
        Print-Success "pip is installed (version $pipVersion)"
        return $true
    }
    catch {
        Print-Warning "pip is not installed"
        Write-Host ""
        Write-Host "pip is optional for this repository but recommended:"
        Write-Host "  - Usually comes with Python"
        Write-Host "  - Install with: python -m ensurepip --upgrade"
        Write-Host ""
        return $true  # Return true since pip is optional
    }
}

###################################################################################
# Main Setup Functions
###################################################################################

function Check-AllDependencies {
    Print-Header "Step 1: Checking Dependencies"
    
    $allRequiredDepsOk = $true
    
    if (-not (Check-Git)) { $allRequiredDepsOk = $false }
    if (-not (Check-Node)) { $allRequiredDepsOk = $false }
    if (-not (Check-Npm)) { $allRequiredDepsOk = $false }
    Check-Python  # Optional, won't affect allRequiredDepsOk
    Check-Pip     # Optional, won't affect allRequiredDepsOk
    
    if (-not $allRequiredDepsOk) {
        Print-Error "Required dependencies are missing. Please install them and run this script again."
        exit 1
    }
    
    Print-Success "All required dependencies are installed!"
}

function Clone-Repository {
    Print-Header "Step 2: Cloning Repository"
    
    if (Test-Path $CLONE_DIR) {
        Print-Warning "Directory '$CLONE_DIR' already exists"
        $response = Read-Host "Do you want to use the existing directory? (y/n)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            Print-Info "Using existing directory: $CLONE_DIR"
            return
        }
        else {
            Print-Info "Removing existing directory..."
            Remove-Item -Recurse -Force $CLONE_DIR
        }
    }
    
    Print-Info "Cloning repository from $REPO_URL..."
    try {
        git clone $REPO_URL $CLONE_DIR
        Print-Success "Repository cloned successfully to '$CLONE_DIR'"
    }
    catch {
        Print-Error "Failed to clone repository: $_"
        exit 1
    }
}

function Navigate-ToRepo {
    Print-Header "Step 3: Navigating to Repository"
    
    if (-not (Test-Path $CLONE_DIR)) {
        Print-Error "Repository directory '$CLONE_DIR' not found"
        exit 1
    }
    
    Set-Location $CLONE_DIR
    Print-Success "Navigated to $(Get-Location)"
}

function Install-Dependencies {
    Print-Header "Step 4: Installing npm Dependencies"
    
    if (-not (Test-Path "package.json")) {
        Print-Error "package.json not found in current directory"
        exit 1
    }
    
    Print-Info "Running npm install... (this may take a few minutes)"
    Print-Warning "Note: Some packages may require GitHub authentication. If you encounter errors,"
    Print-Warning "you may need to set up GitHub package authentication."
    
    try {
        npm install
        Print-Success "Dependencies installed successfully"
    }
    catch {
        Print-Error "Failed to install dependencies"
        Write-Host ""
        Write-Host "If you see authentication errors for @iptv-org packages:"
        Write-Host "1. You may need a GitHub Personal Access Token (PAT)"
        Write-Host "2. Create .npmrc file with: //npm.pkg.github.com/:_authToken=YOUR_TOKEN"
        Write-Host "3. Or continue without authenticated packages (some features may not work)"
        Write-Host ""
        $response = Read-Host "Do you want to continue anyway? (y/n)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            exit 1
        }
    }
}

function Show-DashboardInfo {
    Print-Header "Step 5: Development Environment Ready!"
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                                                                ║" -ForegroundColor Green
    Write-Host "║  🎉 IPTV Repository - Development Environment Setup Complete!  ║" -ForegroundColor Green
    Write-Host "║                                                                ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    Print-Info "Repository Location: $(Get-Location)"
    Write-Host ""
    
    Write-Host "Available Commands:" -ForegroundColor Blue
    Write-Host ""
    Write-Host "  Development & Testing:" -ForegroundColor Yellow
    Write-Host "    npm run lint              - Check scripts for syntax errors"
    Write-Host "    npm run test              - Run all tests"
    Write-Host "    npm run check             - Validate playlists (lint + validate)"
    Write-Host ""
    Write-Host "  Playlist Management:" -ForegroundColor Yellow
    Write-Host "    npm run playlist:format   - Format playlists"
    Write-Host "    npm run playlist:validate - Validate playlist data"
    Write-Host "    npm run playlist:test     - Test playlist streams"
    Write-Host "    npm run playlist:edit     - Quick stream mapping utility"
    Write-Host ""
    Write-Host "  Data Management:" -ForegroundColor Yellow
    Write-Host "    npm run api:load          - Download latest channel data"
    Write-Host "    npm run api:generate      - Generate API JSON files"
    Write-Host "    npm run update            - Update playlists and documentation"
    Write-Host ""
    Write-Host "Getting Started:" -ForegroundColor Blue
    Write-Host ""
    Write-Host "  1. Load the latest channel data:"
    Write-Host "     npm run api:load" -ForegroundColor Green
    Write-Host ""
    Write-Host "  2. Validate your changes:"
    Write-Host "     npm run check" -ForegroundColor Green
    Write-Host ""
    Write-Host "  3. Format playlists:"
    Write-Host "     npm run format" -ForegroundColor Green
    Write-Host ""
    Write-Host "  4. Run tests:"
    Write-Host "     npm test" -ForegroundColor Green
    Write-Host ""
    Write-Host "Documentation:" -ForegroundColor Blue
    Write-Host "  - README.md         - Project overview"
    Write-Host "  - CONTRIBUTING.md   - Contribution guidelines"
    Write-Host "  - FAQ.md            - Frequently asked questions"
    Write-Host ""
    Write-Host "Web Resources:" -ForegroundColor Blue
    Write-Host "  - Channel Database: https://iptv-org.github.io/"
    Write-Host "  - API Documentation: https://github.com/iptv-org/api"
    Write-Host "  - Repository: https://github.com/hochster71-oss/iptv"
    Write-Host ""
    
    Print-Success "Happy developing! 🚀"
    Write-Host ""
}

###################################################################################
# Main Script Execution
###################################################################################

function Main {
    Clear-Host
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Blue
    Write-Host "║                                                              ║" -ForegroundColor Blue
    Write-Host "║        IPTV Repository - Developer Dashboard Setup          ║" -ForegroundColor Blue
    Write-Host "║                                                              ║" -ForegroundColor Blue
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Blue
    Write-Host ""
    
    # If we're already in the iptv repository, offer to skip cloning
    if ((Test-Path "package.json") -and (Get-Content "package.json" -Raw) -match '"name":\s*"iptv"') {
        Print-Info "Detected that you're already in the IPTV repository!"
        $response = Read-Host "Skip cloning and set up current directory? (y/n)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            Check-AllDependencies
            Install-Dependencies
            Show-DashboardInfo
            return
        }
    }
    
    # Full setup process
    Check-AllDependencies
    Clone-Repository
    Navigate-ToRepo
    Install-Dependencies
    Show-DashboardInfo
}

# Run main function
Main
