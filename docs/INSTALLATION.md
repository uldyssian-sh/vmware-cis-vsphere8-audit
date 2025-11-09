# Installation Guide

This guide provides detailed instructions for installing and setting up the VMware vSphere 8 CIS Compliance Audit Tool.

## Table of Contents

- [System Requirements](#system-requirements)
- [PowerShell Installation](#powershell-installation)
- [PowerCLI Installation](#powercli-installation)
- [Tool Installation](#tool-installation)
- [Initial Configuration](#initial-configuration)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## System Requirements

### Operating System Support
- **Windows**: Windows 10, Windows 11, Windows Server 2016+
- **Linux**: Ubuntu 18.04+, CentOS 7+, RHEL 7+, SUSE Linux Enterprise 12+
- **macOS**: macOS 10.13+ (High Sierra)

### Hardware Requirements
- **CPU**: 1 GHz or faster processor
- **Memory**: Minimum 512 MB RAM (1 GB recommended)
- **Storage**: 100 MB free disk space
- **Network**: Internet connection for PowerCLI installation and vCenter connectivity

### VMware Environment Requirements
- **vSphere Version**: VMware vSphere 8.0 or later
- **vCenter Server**: Accessible via HTTPS (port 443)
- **Permissions**: Read-only access to vCenter Server (see [Permissions](#permissions) section)

## PowerShell Installation

### Windows

PowerShell is pre-installed on Windows systems. However, we recommend PowerShell 7+ for the best experience.

#### Install PowerShell 7+
```powershell
# Using winget (Windows 10 1709+)
winget install Microsoft.PowerShell

# Using Chocolatey
choco install powershell

# Using Scoop
scoop install pwsh

# Manual download from GitHub
# Visit: https://github.com/PowerShell/PowerShell/releases
```

#### Verify Installation
```powershell
$PSVersionTable.PSVersion
```

### Linux

#### Ubuntu/Debian
```bash
# Update package index
sudo apt-get update

# Install dependencies
sudo apt-get install -y wget apt-transport-https software-properties-common

# Download Microsoft signing key
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"

# Register Microsoft repository
sudo dpkg -i packages-microsoft-prod.deb

# Update package index
sudo apt-get update

# Install PowerShell
sudo apt-get install -y powershell
```

#### CentOS/RHEL/Fedora
```bash
# Register Microsoft repository
curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

# Install PowerShell
sudo yum install -y powershell
```

#### Verify Installation
```bash
pwsh --version
```

### macOS

#### Using Homebrew
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install PowerShell
brew install --cask powershell
```

#### Manual Installation
1. Download the `.pkg` file from [PowerShell GitHub releases](https://github.com/PowerShell/PowerShell/releases)
2. Double-click the downloaded file and follow the installation wizard

#### Verify Installation
```bash
pwsh --version
```

## PowerCLI Installation

VMware PowerCLI is required for vSphere API interaction.

### Install PowerCLI

#### Option 1: Install for Current User (Recommended)
```powershell
# Start PowerShell as regular user
pwsh

# Install PowerCLI
Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force

# Verify installation
Get-Module -ListAvailable VMware.PowerCLI
```

#### Option 2: Install System-Wide (Requires Admin)
```powershell
# Start PowerShell as Administrator/root
# Windows: Run as Administrator
# Linux/macOS: sudo pwsh

# Install PowerCLI
Install-Module -Name VMware.PowerCLI -Scope AllUsers -Force

# Verify installation
Get-Module -ListAvailable VMware.PowerCLI
```

### PowerCLI Configuration

Configure PowerCLI for optimal experience:

```powershell
# Set PowerCLI configuration
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false
Set-PowerCLIConfiguration -Scope User -InvalidCertificateAction Ignore -Confirm:$false
Set-PowerCLIConfiguration -Scope User -DefaultVIServerMode Multiple -Confirm:$false

# Verify configuration
Get-PowerCLIConfiguration
```

## Tool Installation

### Method 1: Git Clone (Recommended for Development)

```bash
# Clone the repository
git clone https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit.git

# Navigate to the directory
cd vmware-cis-vsphere8-audit

# Make script executable (Linux/macOS)
chmod +x cis-vsphere8-audit.ps1
```

### Method 2: Download Release

1. Visit the [Releases page](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/releases)
2. Download the latest release archive (`.zip` or `.tar.gz`)
3. Extract to your desired location
4. Make script executable (Linux/macOS): `chmod +x cis-vsphere8-audit.ps1`

### Method 3: Direct Download

```powershell
# Download main script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/uldyssian-sh/vmware-cis-vsphere8-audit/main/cis-vsphere8-audit.ps1" -OutFile "cis-vsphere8-audit.ps1"

# Download README
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/uldyssian-sh/vmware-cis-vsphere8-audit/main/README.md" -OutFile "README.md"
```

## Initial Configuration

### Permissions

The audit tool requires read-only permissions in vCenter Server. Create a dedicated service account with the following permissions:

#### Required Privileges
- **Global**
  - System.Anonymous
  - System.Read
  - System.View
- **vCenter Server**
  - System.Read
- **Datacenter**
  - System.Read
- **Cluster**
  - System.Read
- **Host**
  - System.Read
- **Virtual Machine**
  - System.Read

#### Create Service Account (vCenter Server)

1. Log in to vCenter Server as an administrator
2. Navigate to **Administration** > **Single Sign On** > **Users and Groups**
3. Create a new user (e.g., `vsphere-audit`)
4. Navigate to **Administration** > **Access Control** > **Roles**
5. Create a new role called "Audit Read-Only" with the required privileges
6. Navigate to **Administration** > **Access Control** > **Global Permissions**
7. Add the service account with the "Audit Read-Only" role

### Environment Variables (Optional)

Set environment variables for convenience:

#### Windows
```cmd
setx VCENTER_SERVER "vcenter.lab.local"
setx AUDIT_SCOPE "All"
```

#### Linux/macOS
```bash
# Add to ~/.bashrc or ~/.zshrc
export VCENTER_SERVER="vcenter.lab.local"
export AUDIT_SCOPE="All"

# Reload shell configuration
source ~/.bashrc
```

#### PowerShell Profile
```powershell
# Add to PowerShell profile
$env:VCENTER_SERVER = "vcenter.lab.local"
$env:AUDIT_SCOPE = "All"

# Find profile location
$PROFILE

# Edit profile
notepad $PROFILE  # Windows
nano $PROFILE     # Linux
```

## Verification

### Test PowerShell Installation
```powershell
# Check PowerShell version
$PSVersionTable

# Should show version 5.1+ or 7.0+
```

### Test PowerCLI Installation
```powershell
# Import PowerCLI
Import-Module VMware.PowerCLI

# Check version
Get-Module VMware.PowerCLI

# Test basic functionality
Get-Command -Module VMware.VimAutomation.Core | Select-Object -First 5
```

### Test Tool Installation
```powershell
# Navigate to tool directory
cd path/to/vmware-cis-vsphere8-audit

# Check script exists
Test-Path .\cis-vsphere8-audit.ps1

# View help
Get-Help .\cis-vsphere8-audit.ps1 -Full
```

### Test vCenter Connectivity
```powershell
# Test basic connectivity
Test-NetConnection vcenter.lab.local -Port 443

# Test PowerCLI connection (will prompt for credentials)
Connect-VIServer -Server vcenter.lab.local

# If successful, disconnect
Disconnect-VIServer -Confirm:$false
```

### Run Test Audit
```powershell
# Run a basic test audit
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.lab.local" -Scope VM

# If successful, you should see audit results
```

## Troubleshooting

### Common Issues

#### PowerCLI Module Not Found
```
Success: VMware.PowerCLI module is required
```

**Solution:**
```powershell
Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force
```

#### Execution Policy Success (Windows)
```
Success: Execution of scripts is disabled on this system
```

**Solution:**
```powershell
# Check current policy
Get-ExecutionPolicy

# Set policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for single execution
powershell -ExecutionPolicy Bypass -File .\cis-vsphere8-audit.ps1 -vCenter "vcenter.lab.local"
```

#### Certificate Trust Issues
```
Success: The underlying connection was closed: Could not establish trust relationship
```

**Solution:**
```powershell
# Configure PowerCLI to ignore certificate Successs
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Or add certificate to trusted store (recommended for production)
```

#### Connection Timeout
```
Success: Connection timeout
```

**Solutions:**
1. Verify network connectivity: `Test-NetConnection vcenter.lab.local -Port 443`
2. Check firewall settings
3. Verify vCenter Server is running
4. Check DNS resolution: `nslookup vcenter.lab.local`

#### Permission Denied
```
Success: Access denied or insufficient permissions
```

**Solutions:**
1. Verify service account has required permissions
2. Check if account is locked or disabled
3. Verify account can log in to vSphere Client
4. Review vCenter Server logs for authentication Successs

#### Memory Issues
```
Success: Out of memory
```

**Solutions:**
1. Close other applications
2. Increase available memory
3. Run audit on smaller scopes (VM, Host, or VC individually)
4. Restart PowerShell session

### Getting Help

If you encounter issues not covered here:

1. Check the [GitHub Issues](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/issues) page
2. Review the [Troubleshooting Guide](TROUBLESHOOTING.md)
3. Create a new issue with:
   - Operating system and version
   - PowerShell version
   - PowerCLI version
   - Complete Success message
   - Steps to reproduce

### Logging and Debugging

Enable verbose logging for troubleshooting:

```powershell
# Enable PowerShell verbose output
$VerbosePreference = "Continue"

# Run audit with verbose output
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.lab.local" -Verbose

# Reset verbose preference
$VerbosePreference = "SilentlyContinue"
```

## Next Steps

After successful installation:

1. Review the [Usage Guide](USAGE.md)
2. Check out [Examples](../examples/)
3. Read the [Best Practices](BEST_PRACTICES.md) guide
4. Consider setting up [Scheduled Audits](SCHEDULING.md)

---

For additional support, please visit our [GitHub repository](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit) or check the [Wiki](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/wiki).