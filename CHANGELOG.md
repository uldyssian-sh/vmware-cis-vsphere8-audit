# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Enterprise-grade CI/CD pipeline with security scanning
- Automated code quality checks with PSScriptAnalyzer
- Pre-commit hooks for code quality enforcement
- Comprehensive security policy and vulnerability reporting
- Release automation with GitHub Actions
- EditorConfig for consistent code formatting
- PyProject.toml for modern Python packaging
- Trivy vulnerability scanning integration
- TruffleHog secret detection
- SARIF security reporting

### Changed
- Updated GitHub Actions to use latest versions (checkout@v4)
- Improved package.json with scoped npm package name (@uldyssian-sh/vmware-cis-vsphere8-audit)
- Enhanced README.md with detailed audit check documentation
- Standardized dependabot configuration across all ecosystems
- Optimized workflows to use only 'main' branch (removed 'master')
- Enhanced error handling and logging
- Improved output formatting
- Better parameter validation

### Fixed
- Resolved hardcoded repository references in workflows
- Fixed inconsistent ignore configurations in dependabot.yml
- Corrected npm package scoping for security compliance
- Updated deprecated GitHub Actions versions
- Minor bug fixes in host acceptance level detection

### Security
- Added comprehensive security scanning pipeline
- Implemented automated vulnerability detection
- Enhanced PowerShell script analysis with security rules
- Added security policy documentation

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
- **Security** in case of vulnerabilities# Updated 20251109_123817
