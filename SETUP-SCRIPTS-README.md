# Developer Dashboard Setup Scripts

This directory contains automated setup scripts that help you quickly set up and run a local developer environment for the IPTV repository.

## Overview

These scripts automate the process of:
1. Checking for required dependencies (Node.js, npm, Python, pip, Git)
2. Cloning the repository (if not already in it)
3. Installing npm dependencies
4. Providing a developer dashboard with available commands and resources

## Available Scripts

### For Linux and macOS

**`setup-dev-dashboard.sh`** - Bash script for Unix-like systems

```bash
# Make the script executable (first time only)
chmod +x setup-dev-dashboard.sh

# Run the script
./setup-dev-dashboard.sh
```

### For Windows

**Option 1: PowerShell (Recommended)**

**`setup-dev-dashboard.ps1`** - PowerShell script for Windows

```powershell
# You may need to allow script execution first (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the script
.\setup-dev-dashboard.ps1
```

**Option 2: Command Prompt**

**`setup-dev-dashboard.bat`** - Batch script for Windows

```cmd
# Simply double-click the file or run from command prompt
setup-dev-dashboard.bat
```

### Alternative: Using Git Bash on Windows

If you have Git Bash installed on Windows, you can also use the bash script:

```bash
./setup-dev-dashboard.sh
```

## Requirements

### Required Dependencies
- **Git** - For cloning the repository
- **Node.js** (v18.x or higher recommended) - JavaScript runtime
- **npm** - Node.js package manager (comes with Node.js)

### Optional Dependencies
- **Python** (v3.x) - For potential Python-based tools
- **pip** - Python package manager (usually comes with Python)

## Features

### Smart Detection
- Automatically detects if you're already in the IPTV repository
- Offers to skip cloning if already in the correct directory
- Checks for existing directories and asks before overwriting

### Error Handling
- Validates each dependency before proceeding
- Provides clear error messages with installation instructions
- Offers recovery options when npm install encounters issues

### Cross-Platform Support
- Works on Linux, macOS, and Windows
- Adapts to different command-line environments
- Uses appropriate package manager commands for each OS

### Developer-Friendly Output
- Color-coded console output for better readability
- Clear step-by-step progress indicators
- Comprehensive list of available npm commands
- Quick-start guide and documentation links

## Installation Instructions for Dependencies

### Git

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install git
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install git
```

**macOS:**
```bash
# Using Homebrew
brew install git

# Or download from https://git-scm.com/download/mac
```

**Windows:**
- Download from [https://git-scm.com/download/win](https://git-scm.com/download/win)
- Or use Chocolatey: `choco install git`
- Or use winget: `winget install Git.Git`

### Node.js and npm

**Linux (Ubuntu/Debian):**
```bash
# Using NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install nodejs npm
```

**macOS:**
```bash
# Using Homebrew
brew install node
```

**Windows:**
- Download from [https://nodejs.org/](https://nodejs.org/)
- Or use Chocolatey: `choco install nodejs`
- Or use winget: `winget install OpenJS.NodeJS`

### Python and pip (Optional)

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install python3 python3-pip
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install python3 python3-pip
```

**macOS:**
```bash
# Using Homebrew
brew install python3
```

**Windows:**
- Download from [https://www.python.org/downloads/](https://www.python.org/downloads/)
- Or use Chocolatey: `choco install python`
- Or use winget: `winget install Python.Python.3`

## Troubleshooting

### GitHub Package Authentication Error

If you encounter authentication errors for `@iptv-org` packages during `npm install`:

1. **Create a GitHub Personal Access Token (PAT):**
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Click "Generate new token (classic)"
   - Select the `read:packages` scope
   - Generate and copy the token

2. **Create or update `.npmrc` file in your home directory:**
   ```
   //npm.pkg.github.com/:_authToken=YOUR_TOKEN_HERE
   ```

3. **Or continue without authenticated packages:**
   - Some features may not work, but basic functionality should be available
   - The script will prompt you to continue even if authentication fails

### Permission Denied on Linux/macOS

If you get "Permission denied" when running the bash script:

```bash
chmod +x setup-dev-dashboard.sh
```

### PowerShell Script Execution Policy

If PowerShell blocks script execution:

```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Node.js Version Issues

If you need a specific Node.js version, consider using a version manager:

**Linux/macOS:**
- Use `nvm` (Node Version Manager): [https://github.com/nvm-sh/nvm](https://github.com/nvm-sh/nvm)

**Windows:**
- Use `nvm-windows`: [https://github.com/coreybutler/nvm-windows](https://github.com/coreybutler/nvm-windows)

## Available NPM Commands After Setup

Once setup is complete, you'll have access to these commands:

### Development & Testing
- `npm run lint` - Check scripts for syntax errors
- `npm run test` - Run all tests
- `npm run check` - Validate playlists (lint + validate)

### Playlist Management
- `npm run playlist:format` - Format playlists
- `npm run playlist:validate` - Validate playlist data
- `npm run playlist:test` - Test playlist streams
- `npm run playlist:edit` - Quick stream mapping utility

### Data Management
- `npm run api:load` - Download latest channel data
- `npm run api:generate` - Generate API JSON files
- `npm run update` - Update playlists and documentation

## Getting Started After Setup

1. **Load the latest channel data:**
   ```bash
   npm run api:load
   ```

2. **Validate your changes:**
   ```bash
   npm run check
   ```

3. **Format playlists:**
   ```bash
   npm run format
   ```

4. **Run tests:**
   ```bash
   npm test
   ```

## Additional Resources

- **README.md** - Project overview
- **CONTRIBUTING.md** - Contribution guidelines and detailed script descriptions
- **FAQ.md** - Frequently asked questions
- **Channel Database:** [https://iptv-org.github.io/](https://iptv-org.github.io/)
- **API Documentation:** [https://github.com/iptv-org/api](https://github.com/iptv-org/api)
- **Main Repository:** [https://github.com/hochster71-oss/iptv](https://github.com/hochster71-oss/iptv)

## Contributing

If you find issues with these setup scripts or have suggestions for improvements, please:

1. Check existing issues on GitHub
2. Create a new issue with details about the problem
3. Submit a pull request with your proposed changes

## License

These setup scripts are part of the IPTV repository and follow the same license (MIT). See the LICENSE file for details.
