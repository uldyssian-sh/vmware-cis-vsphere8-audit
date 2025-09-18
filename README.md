# VMware vSphere 8 CIS Compliance Audit Tool

[![GitHub license](https://img.shields.io/github/license/uldyssian-sh/vmware-cis-vsphere8-audit)](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/blob/main/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/uldyssian-sh/vmware-cis-vsphere8-audit)](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/issues)
[![GitHub stars](https://img.shields.io/github/stars/uldyssian-sh/vmware-cis-vsphere8-audit)](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/stargazers)
[![CI](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/workflows/CI/badge.svg)](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/actions)
[![Security](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/workflows/Security%20Scan/badge.svg)](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/actions)
[![Quality](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/workflows/Code%20Quality/badge.svg)](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/actions)

## 📋 Overview

A comprehensive PowerShell-based audit tool for VMware vSphere 8 environments that performs read-only compliance checks against CIS (Center for Internet Security) benchmarks and VMware hardening guidelines.

**Repository Type:** Security & Compliance Tool  
**Technology Stack:** PowerShell, VMware PowerCLI, vSphere API

## ✨ Features

- 🔍 **Comprehensive Auditing** - Covers VM, ESXi Host, and vCenter security configurations
- 🔒 **Read-Only Operations** - No configuration changes, safe for production environments
- 📊 **Detailed Reporting** - Summary tables and detailed failure analysis
- 🎯 **CIS Compliance** - Aligned with CIS benchmarks and VMware security guidelines
- ⚡ **PowerCLI Integration** - Leverages VMware PowerCLI for reliable API access
- 🔧 **Flexible Scoping** - Audit specific components (VM, Host, vCenter) or all
- 📚 **Enterprise Ready** - Designed for large-scale VMware environments
- 🧪 **Thoroughly Tested** - Comprehensive test coverage with automated CI/CD

## 🚀 Quick Start

### Prerequisites

- **PowerShell 5.1+** or **PowerShell Core 7+**
- **VMware PowerCLI 13+** (`Install-Module VMware.PowerCLI`)
- **Network access** to vCenter Server
- **Read permissions** on vSphere environment

### Installation

```bash
# Clone repository
git clone https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit.git
cd vmware-cis-vsphere8-audit

# Install VMware PowerCLI (if not already installed)
Install-Module VMware.PowerCLI -Force -AllowClobber
```

### Basic Usage

```powershell
# Run complete audit against all components
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.example.com"

# Audit only virtual machines
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.example.com" -Scope VM

# Show detailed failure information
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.example.com" -ShowFailures
```

## 📖 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Usage Examples](examples/)
- [Test Suite](tests/)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)

## 🔧 Configuration

### Command Line Parameters

- **`-vCenter`** (Required): vCenter Server FQDN or IP address
- **`-Scope`** (Optional): Audit scope - `VM`, `Host`, `VC`, or `All` (default: `All`)
- **`-ShowFailures`** (Optional): Display detailed failure information

### Supported Audit Scopes

| Scope | Description | Checks |
|-------|-------------|--------|
| `VM` | Virtual Machine security settings | 16 checks covering isolation, firmware, devices |
| `Host` | ESXi Host configuration | 7 checks covering services, NTP, logging, lockdown |
| `VC` | vCenter Server policies | 5 checks covering SSO policies and logging |
| `All` | Complete environment audit | All 28 security checks |

## 📊 Audit Checks Overview

### Virtual Machine Checks (VM-01 to VM-16)
- Console isolation settings (copy/paste/drag&drop)
- Device connectivity restrictions
- Firmware and Secure Boot configuration
- Legacy device removal (serial, parallel, floppy)
- CD/DVD connection policies

### ESXi Host Checks (HST-01 to HST-07)
- SSH and ESXi Shell service management
- NTP configuration and synchronization
- Syslog configuration
- Software acceptance levels
- Lockdown mode settings

### vCenter Server Checks (VC-01 to VC-05)
- SSO password policies
- Account lockout policies
- Logging configuration

## 🧪 Testing

Run the PowerShell test suite:

```powershell
# Run all tests
.\tests\Run-Tests.ps1

# Run specific test categories
Invoke-Pester .\tests\Unit\ -Verbose
Invoke-Pester .\tests\Integration\ -Verbose

# Run with code coverage
Invoke-Pester -CodeCoverage .\cis-vsphere8-audit.ps1
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md).

### Development Setup

```bash
# Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/vmware-cis-vsphere8-audit.git
cd vmware-cis-vsphere8-audit

# Install development dependencies
pip install -r requirements.txt

# Install pre-commit hooks
pre-commit install

# Install PowerShell modules
Install-Module VMware.PowerCLI, Pester, PSScriptAnalyzer -Force
```

### Pull Request Process

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 🐛 **Bug Reports**: [Issue Tracker](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/issues)
- 💡 **Feature Requests**: [GitHub Issues](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/issues/new)
- 📖 **Documentation**: [Wiki](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/wiki)

## 🙏 Acknowledgments

- **VMware Community** - For PowerCLI and vSphere API documentation
- **CIS (Center for Internet Security)** - For security benchmarks and guidelines
- **Enterprise Security Teams** - For real-world testing and feedback
- **Open Source Contributors** - For continuous improvements and bug fixes

## 📈 Project Stats

![GitHub repo size](https://img.shields.io/github/repo-size/uldyssian-sh/vmware-cis-vsphere8-audit)
![GitHub code size](https://img.shields.io/github/languages/code-size/uldyssian-sh/vmware-cis-vsphere8-audit)
![GitHub last commit](https://img.shields.io/github/last-commit/uldyssian-sh/vmware-cis-vsphere8-audit)
![GitHub contributors](https://img.shields.io/github/contributors/uldyssian-sh/vmware-cis-vsphere8-audit)

---

**Made with ❤️ by [uldyssian-sh](https://github.com/uldyssian-sh)**
<!-- Deployment trigger Wed Sep 17 22:40:48 CEST 2025 -->
