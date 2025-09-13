# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive test suite with Pester
- GitHub Actions CI/CD pipeline
- Wiki documentation
- Contributing guidelines
- Code of conduct

### Changed
- Enhanced error handling and logging
- Improved output formatting
- Better parameter validation

### Fixed
- Minor bug fixes in host acceptance level detection

## [1.0.0] - 2024-01-15

### Added
- Initial release of VMware vSphere 8 CIS Compliance Audit Tool
- Read-only compliance checks for Virtual Machines (16 checks)
- Read-only compliance checks for ESXi Hosts (7 checks)
- Read-only compliance checks for vCenter Server (5 checks)
- PowerCLI integration for vSphere API interaction
- Flexible scoping options (VM, Host, VC, All)
- Console output with summary tables
- Optional detailed failure reporting with `-ShowFailures` parameter
- Support for PowerShell 7+ and Windows PowerShell 5.1+
- Cross-platform compatibility (Windows, Linux, macOS)
- MIT License

### Security
- No credentials stored in scripts
- Read-only operations only
- Secure PowerCLI session configuration

## [0.9.0] - 2024-01-10

### Added
- Beta version with core functionality
- Basic VM security checks
- ESXi host configuration audits
- vCenter Server policy validation

### Changed
- Refactored check functions for better maintainability
- Improved error handling

### Fixed
- PowerCLI module detection issues
- Connection timeout handling

## [0.8.0] - 2024-01-05

### Added
- Alpha version with proof of concept
- Initial VM configuration checks
- Basic reporting functionality

---

## Types of Changes

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** in case of vulnerabilities