# VMware vSphere 8 CIS Compliance Audit Tool

[![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![VMware PowerCLI](https://img.shields.io/badge/PowerCLI-13%2B-green.svg)](https://developer.vmware.com/powercli)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/uldyssian-sh/vmware-cis-vsphere8-audit)](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/issues)
[![GitHub stars](https://img.shields.io/github/stars/uldyssian-sh/vmware-cis-vsphere8-audit)](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/stargazers)

A comprehensive PowerShell-based audit tool for VMware vSphere 8 environments that performs **read-only compliance checks** against CIS (Center for Internet Security) benchmarks and VMware hardening guidelines.

**Author**: LT - [GitHub Profile](https://github.com/uldyssian-sh)

## 🚀 Features

- **Read-Only Operations**: No configuration changes, completely safe to run in production
- **Comprehensive Coverage**: Audits Virtual Machines, ESXi hosts, and vCenter Server
- **CIS Compliance**: Based on CIS VMware vSphere 8 Benchmark recommendations
- **Detailed Reporting**: Console output with summary tables and optional detailed failure reports
- **Flexible Scoping**: Target specific components (VM, Host, vCenter) or run full audit
- **PowerCLI Integration**: Leverages VMware PowerCLI for robust vSphere API interaction

## 📋 Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Audit Checks](#audit-checks)
- [Output Examples](#output-examples)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🔧 Requirements

### System Requirements
- **PowerShell**: 7.0+ (recommended) or Windows PowerShell 5.1+
- **Operating System**: Windows, Linux, or macOS
- **Memory**: Minimum 512MB RAM
- **Network**: Access to vCenter Server on port 443

### VMware Requirements
- **VMware PowerCLI**: Version 13.0 or higher
- **vSphere Version**: VMware vSphere 8.0+
- **Permissions**: Read-only access to vCenter Server

### Required PowerCLI Modules
```powershell
VMware.PowerCLI
VMware.VimAutomation.Core
VMware.VimAutomation.Common
```

## 📦 Installation

### Option 1: Clone Repository
```bash
git clone https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit.git
cd vmware-cis-vsphere8-audit
```

### Option 2: Download Release
Download the latest release from the [Releases page](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/releases).

### Install PowerCLI (if not already installed)
```powershell
# Install PowerCLI for current user
Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force

# Verify installation
Get-Module -ListAvailable VMware.PowerCLI
```

## 🚀 Quick Start

1. **Basic audit of all components:**
```powershell
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.example.com"
```

2. **Audit with detailed failure report:**
```powershell
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.example.com" -ShowFailures
```

3. **Audit only Virtual Machines:**
```powershell
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.example.com" -Scope VM
```

## 📖 Usage

### Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `vCenter` | String | Yes | - | vCenter Server FQDN or IP address |
| `Scope` | String | No | `All` | Audit scope: `VM`, `Host`, `VC`, or `All` |
| `ShowFailures` | Switch | No | `False` | Display detailed list of failed checks |

### Scope Options

- **`VM`**: Audit Virtual Machine configurations only
- **`Host`**: Audit ESXi host configurations only  
- **`VC`**: Audit vCenter Server configurations only
- **`All`**: Comprehensive audit of all components (default)

### Examples

```powershell
# Full audit with credentials prompt
.\cis-vsphere8-audit.ps1 -vCenter "vcsa.lab.local"

# Host-only audit with failure details
.\cis-vsphere8-audit.ps1 -vCenter "10.0.1.100" -Scope Host -ShowFailures

# VM audit for specific environment
.\cis-vsphere8-audit.ps1 -vCenter "prod-vcenter.company.com" -Scope VM
```

## 🔍 Audit Checks

### Virtual Machine Checks (VM-01 to VM-16)

| Check ID | Description | CIS Reference |
|----------|-------------|---------------|
| VM-01 | Disable copy operations | 8.2.1 |
| VM-02 | Disable paste operations | 8.2.2 |
| VM-03 | Disable drag and drop | 8.2.3 |
| VM-04 | Disable GUI options | 8.2.4 |
| VM-05 | Disable disk shrinking | 8.2.5 |
| VM-06 | Disable disk wiping | 8.2.6 |
| VM-07 | Disable device connectivity | 8.2.7 |
| VM-08 | Disable VNC console | 8.2.8 |
| VM-09 | Use EFI firmware | 8.1.1 |
| VM-10 | Enable Secure Boot | 8.1.2 |
| VM-11 | Use vTPM when required | 8.1.3 |
| VM-12 | CD/DVD not connected | 8.3.1 |
| VM-13 | CD/DVD not connect on power | 8.3.2 |
| VM-14 | No legacy serial devices | 8.3.3 |
| VM-15 | No legacy parallel devices | 8.3.4 |
| VM-16 | No floppy devices | 8.3.5 |

### ESXi Host Checks (HST-01 to HST-07)

| Check ID | Description | CIS Reference |
|----------|-------------|---------------|
| HST-01 | SSH service disabled | 5.1 |
| HST-02 | ESXi Shell disabled | 5.2 |
| HST-03 | NTP configured | 5.3 |
| HST-04 | NTP service running | 5.3 |
| HST-05 | Syslog configured | 5.4 |
| HST-06 | Acceptance level trusted | 5.5 |
| HST-07 | DCUI/Lockdown enabled | 5.6 |

### vCenter Server Checks (VC-01 to VC-05)

| Check ID | Description | CIS Reference |
|----------|-------------|---------------|
| VC-01 | Password minimum length ≥ 12 | 2.1 |
| VC-02 | Password history ≥ 5 | 2.2 |
| VC-03 | Lockout threshold ≤ 5 | 2.3 |
| VC-04 | Lockout duration ≥ 15 minutes | 2.4 |
| VC-05 | Logging level configured | 2.5 |

## 📊 Output Examples

### Summary Report
```
=== Compliance Summary (by Check) ===

CheckId                               Passed Failed
-------                               ------ ------
VM-01 Disable copy                         10      0
VM-02 Disable paste                        10      0
VM-03 Disable drag&drop                     9      1
HST-01 SSH service disabled                 5      1
HST-05 Syslog configured                    4      2
VC-01 Password min length >= 12             1      0
```

### Detailed Failures (with -ShowFailures)
```
=== Failed Items (details) ===

CheckId                     Object     Details
-------                     ------     -------
VM-03 Disable drag&drop     test-vm1   isolation.tools.dnd.disable=False
HST-01 SSH service disabled esxi-01    Running=True; Policy=on
HST-05 Syslog configured    esxi-02    Syslog.global.logHost=
```

## ⚙️ Configuration

### PowerCLI Configuration
The script automatically configures PowerCLI session settings:
```powershell
Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Ignore -Confirm:$false
```

### Custom Configuration
For persistent settings, configure PowerCLI globally:
```powershell
# Accept invalid certificates (lab environments)
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Set default VI server mode
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false
```

## 🔧 Troubleshooting

### Common Issues

#### PowerCLI Module Not Found
```
Error: VMware.PowerCLI module is required
```
**Solution:**
```powershell
Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force
```

#### Connection Issues
```
Error: Could not connect to vCenter Server
```
**Solutions:**
- Verify vCenter FQDN/IP is correct
- Check network connectivity: `Test-NetConnection vcenter.example.com -Port 443`
- Verify credentials have sufficient permissions
- Check certificate trust issues

#### Permission Errors
```
Error: Access denied or insufficient permissions
```
**Required Permissions:**
- Global → System.Anonymous
- Global → System.Read
- Global → System.View
- vCenter Server → System.Read

### Debug Mode
Enable verbose output for troubleshooting:
```powershell
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.example.com" -Verbose
```

### Log Files
PowerCLI logs are stored in:
- **Windows**: `%APPDATA%\VMware\vSphere PowerCLI\`
- **Linux/macOS**: `~/.local/share/powershell/VMware/`

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run tests: `.\tests\Run-Tests.ps1`
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Reporting Issues
Please use the [GitHub Issues](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/issues) page to report bugs or request features.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [CIS VMware vSphere 8 Benchmark](https://www.cisecurity.org/benchmark/vmware_vsphere)
- [VMware vSphere Security Configuration Guide](https://docs.vmware.com/en/VMware-vSphere/8.0/vsphere-security/GUID-52188148-C579-4F6A-8335-CFBCE0DD2167.html)
- [VMware PowerCLI Community](https://developer.vmware.com/powercli)

## 📞 Support

- **Documentation**: [Wiki](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/wiki)
- **Issues**: [GitHub Issues](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/discussions)

---

**Disclaimer**: This tool is provided "as is" without warranty. Always test in non-production environments first. Users are responsible for reviewing and validating all configurations in their specific environments.