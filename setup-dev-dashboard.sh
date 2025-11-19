#!/bin/bash

###################################################################################
# IPTV Repository - Developer Dashboard Setup Script
# 
# This script automates the setup and running of a local development environment
# for the hochster71-oss/iptv repository.
#
# Compatible with: Linux, macOS, and Windows (via Git Bash or WSL)
###################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository configuration
REPO_URL="https://github.com/hochster71-oss/iptv.git"
REPO_NAME="iptv"
CLONE_DIR="${REPO_NAME}-dev"

###################################################################################
# Helper Functions
###################################################################################

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ Error: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ Warning: $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

###################################################################################
# Dependency Checking Functions
###################################################################################

check_git() {
    print_info "Checking for Git..."
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version | awk '{print $3}')
        print_success "Git is installed (version $GIT_VERSION)"
        return 0
    else
        print_error "Git is not installed"
        echo ""
        echo "Please install Git:"
        echo "  - Linux (Ubuntu/Debian): sudo apt-get install git"
        echo "  - Linux (Fedora/RHEL): sudo dnf install git"
        echo "  - macOS: brew install git (requires Homebrew)"
        echo "  - Windows: Download from https://git-scm.com/download/win"
        echo ""
        return 1
    fi
}

check_node() {
    print_info "Checking for Node.js..."
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js is installed (version $NODE_VERSION)"
        return 0
    else
        print_error "Node.js is not installed"
        echo ""
        echo "Please install Node.js (version 18.x or higher recommended):"
        echo "  - Visit https://nodejs.org/ to download the installer"
        echo "  - Linux: Use your package manager or Node Version Manager (nvm)"
        echo "  - macOS: brew install node (requires Homebrew)"
        echo "  - Windows: Download from https://nodejs.org/"
        echo ""
        return 1
    fi
}

check_npm() {
    print_info "Checking for npm..."
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        print_success "npm is installed (version $NPM_VERSION)"
        return 0
    else
        print_error "npm is not installed"
        echo ""
        echo "npm usually comes with Node.js. Please install Node.js."
        echo ""
        return 1
    fi
}

check_python() {
    print_info "Checking for Python..."
    
    # Try python3 first, then python
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
        PYTHON_VERSION=$(python3 --version | awk '{print $2}')
        print_success "Python is installed (version $PYTHON_VERSION)"
        return 0
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
        PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}')
        print_success "Python is installed (version $PYTHON_VERSION)"
        return 0
    else
        print_warning "Python is not installed"
        echo ""
        echo "Python is optional for this repository but recommended:"
        echo "  - Linux (Ubuntu/Debian): sudo apt-get install python3 python3-pip"
        echo "  - Linux (Fedora/RHEL): sudo dnf install python3 python3-pip"
        echo "  - macOS: brew install python3 (requires Homebrew)"
        echo "  - Windows: Download from https://www.python.org/downloads/"
        echo ""
        return 0  # Return 0 since Python is optional
    fi
}

check_pip() {
    print_info "Checking for pip..."
    
    # Try pip3 first, then pip
    if command -v pip3 &> /dev/null; then
        PIP_VERSION=$(pip3 --version | awk '{print $2}')
        print_success "pip is installed (version $PIP_VERSION)"
        return 0
    elif command -v pip &> /dev/null; then
        PIP_VERSION=$(pip --version | awk '{print $2}')
        print_success "pip is installed (version $PIP_VERSION)"
        return 0
    else
        print_warning "pip is not installed"
        echo ""
        echo "pip is optional for this repository but recommended:"
        echo "  - Usually comes with Python"
        echo "  - Linux/macOS: Install with 'python3 -m ensurepip --upgrade'"
        echo "  - Windows: Usually included with Python installer"
        echo ""
        return 0  # Return 0 since pip is optional
    fi
}

###################################################################################
# Main Setup Functions
###################################################################################

check_all_dependencies() {
    print_header "Step 1: Checking Dependencies"
    
    local all_required_deps_ok=true
    
    check_git || all_required_deps_ok=false
    check_node || all_required_deps_ok=false
    check_npm || all_required_deps_ok=false
    check_python  # Optional, won't affect all_required_deps_ok
    check_pip     # Optional, won't affect all_required_deps_ok
    
    if [ "$all_required_deps_ok" = false ]; then
        print_error "Required dependencies are missing. Please install them and run this script again."
        exit 1
    fi
    
    print_success "All required dependencies are installed!"
}

clone_repository() {
    print_header "Step 2: Cloning Repository"
    
    if [ -d "$CLONE_DIR" ]; then
        print_warning "Directory '$CLONE_DIR' already exists"
        read -p "Do you want to use the existing directory? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Using existing directory: $CLONE_DIR"
            return 0
        else
            print_info "Removing existing directory..."
            rm -rf "$CLONE_DIR"
        fi
    fi
    
    print_info "Cloning repository from $REPO_URL..."
    if git clone "$REPO_URL" "$CLONE_DIR"; then
        print_success "Repository cloned successfully to '$CLONE_DIR'"
    else
        print_error "Failed to clone repository"
        exit 1
    fi
}

navigate_to_repo() {
    print_header "Step 3: Navigating to Repository"
    
    if [ ! -d "$CLONE_DIR" ]; then
        print_error "Repository directory '$CLONE_DIR' not found"
        exit 1
    fi
    
    cd "$CLONE_DIR"
    print_success "Navigated to $(pwd)"
}

install_dependencies() {
    print_header "Step 4: Installing npm Dependencies"
    
    if [ ! -f "package.json" ]; then
        print_error "package.json not found in current directory"
        exit 1
    fi
    
    print_info "Running npm install... (this may take a few minutes)"
    print_warning "Note: Some packages may require GitHub authentication. If you encounter errors,"
    print_warning "you may need to set up GitHub package authentication."
    
    if npm install; then
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies"
        echo ""
        echo "If you see authentication errors for @iptv-org packages:"
        echo "1. You may need a GitHub Personal Access Token (PAT)"
        echo "2. Create .npmrc file with: //npm.pkg.github.com/:_authToken=YOUR_TOKEN"
        echo "3. Or continue without authenticated packages (some features may not work)"
        echo ""
        read -p "Do you want to continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

show_dashboard_info() {
    print_header "Step 5: Development Environment Ready!"
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                ║${NC}"
    echo -e "${GREEN}║  🎉 IPTV Repository - Development Environment Setup Complete!  ║${NC}"
    echo -e "${GREEN}║                                                                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_info "Repository Location: $(pwd)"
    echo ""
    
    echo -e "${BLUE}Available Commands:${NC}"
    echo ""
    echo -e "  ${YELLOW}Development & Testing:${NC}"
    echo "    npm run lint              - Check scripts for syntax errors"
    echo "    npm run test              - Run all tests"
    echo "    npm run check             - Validate playlists (lint + validate)"
    echo ""
    echo -e "  ${YELLOW}Playlist Management:${NC}"
    echo "    npm run playlist:format   - Format playlists"
    echo "    npm run playlist:validate - Validate playlist data"
    echo "    npm run playlist:test     - Test playlist streams"
    echo "    npm run playlist:edit     - Quick stream mapping utility"
    echo ""
    echo -e "  ${YELLOW}Data Management:${NC}"
    echo "    npm run api:load          - Download latest channel data"
    echo "    npm run api:generate      - Generate API JSON files"
    echo "    npm run update            - Update playlists and documentation"
    echo ""
    echo -e "${BLUE}Getting Started:${NC}"
    echo ""
    echo "  1. Load the latest channel data:"
    echo -e "     ${GREEN}npm run api:load${NC}"
    echo ""
    echo "  2. Validate your changes:"
    echo -e "     ${GREEN}npm run check${NC}"
    echo ""
    echo "  3. Format playlists:"
    echo -e "     ${GREEN}npm run format${NC}"
    echo ""
    echo "  4. Run tests:"
    echo -e "     ${GREEN}npm test${NC}"
    echo ""
    echo -e "${BLUE}Documentation:${NC}"
    echo "  - README.md         - Project overview"
    echo "  - CONTRIBUTING.md   - Contribution guidelines"
    echo "  - FAQ.md            - Frequently asked questions"
    echo ""
    echo -e "${BLUE}Web Resources:${NC}"
    echo "  - Channel Database: https://iptv-org.github.io/"
    echo "  - API Documentation: https://github.com/iptv-org/api"
    echo "  - Repository: https://github.com/hochster71-oss/iptv"
    echo ""
    
    print_success "Happy developing! 🚀"
    echo ""
}

###################################################################################
# Main Script Execution
###################################################################################

main() {
    clear
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                                                              ║${NC}"
    echo -e "${BLUE}║        IPTV Repository - Developer Dashboard Setup          ║${NC}"
    echo -e "${BLUE}║                                                              ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # If we're already in the iptv repository, offer to skip cloning
    if [ -f "package.json" ] && grep -q '"name": "iptv"' package.json 2>/dev/null; then
        print_info "Detected that you're already in the IPTV repository!"
        read -p "Skip cloning and set up current directory? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            check_all_dependencies
            install_dependencies
            show_dashboard_info
            return 0
        fi
    fi
    
    # Full setup process
    check_all_dependencies
    clone_repository
    navigate_to_repo
    install_dependencies
    show_dashboard_info
}

# Run main function
main
