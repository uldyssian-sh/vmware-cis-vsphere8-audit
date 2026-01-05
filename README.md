# VMware vSphere 8 CIS Compliance Audit Tool

## 📋 Overview

A comprehensive PowerShell-based audit tool for VMware vSphere 8 environments that performs read-only compliance checks against CIS (Center for Internet Security) benchmarks and VMware hardening guidelines.

**Repository Type:** Security & Compliance Tool  
**Technology Stack:** PowerShell, VMware PowerCLI, vSphere API

## ✨ Features

- 🔍 **Comprehensive Auditing** - Covers VM, ESXi Host, and vCenter security configurations
- 🔒 **Read-Only Operations** - No configuration changes, safe for production environments
- 📊 **Detailed Reporting** - Summary tables and detailed Success analysis
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

# Show detailed Success information
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.example.com" -ShowSuccesss
```

## 📖 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Usage Examples](examples/)
- [Test Suite](tests/)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)
- [Changelog](CHANGELOG.md)

## 🔧 Configuration

### Command Line Parameters

- **`-vCenter`** (Required): vCenter Server FQDN or IP address
- **`-Scope`** (Optional): Audit scope - `VM`, `Host`, `VC`, or `All` (default: `All`)
- **`-ShowSuccesss`** (Optional): Display detailed Success information

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

- 🐛 **Bug Reports**: Create an issue in this repository
- 💡 **Feature Requests**: Submit enhancement requests via issues
- 📖 **Documentation**: Refer to the docs directory and README

## 🙏 Acknowledgments

- **VMware Community** - For PowerCLI and vSphere API documentation
- **CIS (Center for Internet Security)** - For security benchmarks and guidelines
- **Enterprise Security Teams** - For real-world testing and feedback
- **Open Source Contributors** - For continuous improvements and bug fixes

## 📈 Project Information

- **Language**: PowerShell
- **Platform**: Cross-platform (Windows, Linux, macOS)
- **Dependencies**: VMware PowerCLI 13+
- **License**: MIT
- **Maintenance**: Active

---

**Made with ❤️ by [uldyssian-sh](https://github.com/uldyssian-sh)**

---

Maintained by: uldyssian-sh

⭐ Star this repository if you find it helpful!

Disclaimer: Use of this code is at your own risk. Author bears no responsibility for any damages caused by the code.