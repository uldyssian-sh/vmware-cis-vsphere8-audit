# Contributing to VMware vSphere 8 CIS Compliance Audit Tool

Thank you for your interest in contributing to this project! We welcome contributions from the community and are pleased to have you join us.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Issue Reporting](#issue-reporting)

## 📜 Code of Conduct

This project adheres to a code of conduct that we expect all contributors to follow. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing.

## 🚀 Getting Started

### Prerequisites

- PowerShell 7.0+ or Windows PowerShell 5.1+
- VMware PowerCLI 13.0+
- Git
- A VMware vSphere 8 lab environment for testing

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
```bash
git clone https://github.com/YOUR-USERNAME/vmware-cis-vsphere8-audit.git
cd vmware-cis-vsphere8-audit
```

3. Add the upstream repository:
```bash
git remote add upstream https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit.git
```

## 🛠️ Development Environment

### Required Tools

- **PowerShell**: Latest stable version
- **VMware PowerCLI**: `Install-Module VMware.PowerCLI`
- **Pester**: For testing - `Install-Module Pester`
- **PSScriptAnalyzer**: For code analysis - `Install-Module PSScriptAnalyzer`

### Environment Setup

```powershell
# Install development dependencies
Install-Module -Name Pester -Force -SkipPublisherCheck
Install-Module -Name PSScriptAnalyzer -Force
Install-Module -Name VMware.PowerCLI -Force

# Verify installation
Get-Module -ListAvailable Pester, PSScriptAnalyzer, VMware.PowerCLI
```

## 🤝 How to Contribute

### Types of Contributions

We welcome several types of contributions:

- **Bug fixes**: Fix issues in existing code
- **New features**: Add new audit checks or functionality
- **Documentation**: Improve or add documentation
- **Tests**: Add or improve test coverage
- **Performance**: Optimize existing code

### Before You Start

1. Check existing [issues](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/issues) and [pull requests](https://github.com/uldyssian-sh/vmware-cis-vsphere8-audit/pulls)
2. Create an issue to discuss major changes
3. Ensure your contribution aligns with project goals

## 🔄 Pull Request Process

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b bugfix/issue-number
```

### 2. Make Changes

- Follow our [coding standards](#coding-standards)
- Add tests for new functionality
- Update documentation as needed
- Ensure all tests pass

### 3. Commit Changes

Use clear, descriptive commit messages:

```bash
git add .
git commit -m "Add new VM security check for USB controller"
```

### 4. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub with:
- Clear title and description
- Reference to related issues
- Screenshots if applicable
- Test results

### 5. Code Review

- Address reviewer feedback
- Keep PR updated with main branch
- Ensure CI checks pass

## 📝 Coding Standards

### PowerShell Style Guide

Follow these conventions:

#### Naming Conventions
```powershell
# Functions: Use approved verbs and PascalCase
function Get-VMSecuritySetting { }

# Variables: Use camelCase
$vmHostList = @()
$isSecureBootEnabled = $true

# Parameters: Use PascalCase
param(
    [string]$VCenterServer,
    [switch]$ShowDetails
)
```

#### Code Structure
```powershell
# Use proper indentation (4 spaces)
if ($condition) {
    Write-Host "Message"
    foreach ($item in $collection) {
        # Process item
    }
}

# Use splatting for multiple parameters
$params = @{
    VMHost = $vmHost
    Name = 'SSH'
    ErrorAction = 'SilentlyContinue'
}
$service = Get-VMHostService @params
```

#### Error Handling
```powershell
# Use try-catch for error handling
try {
    $result = Get-SomeData -ErrorAction Stop
} catch {
    Write-Warning "Failed to retrieve data: $($_.Exception.Message)"
    return $false
}
```

#### Comments and Documentation
```powershell
<#
.SYNOPSIS
    Brief description of function

.DESCRIPTION
    Detailed description of what the function does

.PARAMETER ParameterName
    Description of parameter

.EXAMPLE
    Example of how to use the function

.NOTES
    Additional notes
#>
function Get-Example {
    param(
        [Parameter(Mandatory)]
        [string]$ParameterName
    )

    # Implementation
}
```

### Code Analysis

Run PSScriptAnalyzer before submitting:

```powershell
Invoke-ScriptAnalyzer -Path .\cis-vsphere8-audit.ps1 -Severity Warning
```

## 🧪 Testing Guidelines

### Test Structure

Tests are located in the `tests/` directory:

```
tests/
├── Unit/
│   ├── VM.Tests.ps1
│   ├── Host.Tests.ps1
│   └── VCenter.Tests.ps1
├── Integration/
│   └── FullAudit.Tests.ps1
└── TestHelpers/
    └── MockData.ps1
```

### Writing Tests

Use Pester for testing:

```powershell
Describe "VM Security Checks" {
    Context "When checking copy/paste settings" {
        It "Should detect disabled copy operations" {
            # Arrange
            $mockVM = New-MockVM -Name "TestVM"

            # Act
            $result = Test-VMCopyDisabled -VM $mockVM

            # Assert
            $result | Should -Be $true
        }
    }
}
```

### Running Tests

```powershell
# Run all tests
.\tests\Run-Tests.ps1

# Run specific test file
Invoke-Pester -Path .\tests\Unit\VM.Tests.ps1

# Run with coverage
Invoke-Pester -Path .\tests\ -CodeCoverage .\cis-vsphere8-audit.ps1
```

## 📚 Documentation

### Documentation Standards

- Use clear, concise language
- Include code examples
- Update README.md for new features
- Add inline comments for complex logic
- Update Wiki pages as needed

### Documentation Files

- `README.md`: Main project documentation
- `CONTRIBUTING.md`: This file
- `docs/`: Additional documentation
- `examples/`: Usage examples
- Wiki: Detailed guides and tutorials

## 🐛 Issue Reporting

### Before Creating an Issue

1. Search existing issues
2. Check if it's already fixed in latest version
3. Gather relevant information

### Issue Template

When creating an issue, include:

- **Environment**: OS, PowerShell version, PowerCLI version
- **vSphere Environment**: vCenter version, ESXi version
- **Steps to Reproduce**: Clear, numbered steps
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Error Messages**: Full error text
- **Additional Context**: Screenshots, logs, etc.

### Issue Labels

We use these labels:

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements to documentation
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention needed
- `question`: Further information requested

## 🏷️ Release Process

### Versioning

We use [Semantic Versioning](https://semver.org/):

- `MAJOR.MINOR.PATCH`
- Major: Breaking changes
- Minor: New features (backward compatible)
- Patch: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version number updated
- [ ] CHANGELOG.md updated
- [ ] Release notes prepared

## 🎯 Development Roadmap

### Planned Features

- Additional CIS benchmark checks
- JSON/XML output formats
- Configuration file support
- Remediation suggestions
- Integration with CI/CD pipelines

### Areas for Contribution

- Performance optimization
- Additional output formats
- More comprehensive testing
- Documentation improvements
- Internationalization

## 💬 Communication

### Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Pull Requests**: Code review and discussion

### Response Times

- Issues: We aim to respond within 48 hours
- Pull Requests: Initial review within 72 hours
- Security Issues: Within 24 hours

## 🙏 Recognition

Contributors will be recognized in:

- README.md contributors section
- Release notes
- GitHub contributors page

Thank you for contributing to making VMware environments more secure!

---

For questions about contributing, please create an issue or start a discussion on GitHub.