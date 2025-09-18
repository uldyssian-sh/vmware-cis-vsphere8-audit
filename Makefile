.PHONY: help install test lint format security audit clean setup-dev
.DEFAULT_GOAL := help

# Variables
PYTHON := python3
PIP := pip3
POWERSHELL := pwsh

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	@echo "Installing Python dependencies..."
	$(PIP) install -r requirements.txt
	@echo "Installing PowerShell modules..."
	$(POWERSHELL) -Command "Install-Module VMware.PowerCLI, Pester, PSScriptAnalyzer -Force -AllowClobber"

setup-dev: install ## Setup development environment
	@echo "Setting up development environment..."
	$(PIP) install pre-commit black flake8 mypy
	pre-commit install
	@echo "Development environment ready!"

test: ## Run all tests
	@echo "Running PowerShell tests..."
	$(POWERSHELL) -Command "./tests/Run-Tests.ps1"
	@echo "Running Python tests..."
	pytest tests/ -v

test-unit: ## Run unit tests only
	@echo "Running PowerShell unit tests..."
	$(POWERSHELL) -Command "Invoke-Pester ./tests/Unit/ -Verbose"

test-integration: ## Run integration tests only
	@echo "Running PowerShell integration tests..."
	$(POWERSHELL) -Command "Invoke-Pester ./tests/Integration/ -Verbose"

lint: ## Run linting checks
	@echo "Running PSScriptAnalyzer..."
	$(POWERSHELL) -Command "Invoke-ScriptAnalyzer -Path . -Recurse -Settings PSScriptAnalyzerSettings.psd1"
	@echo "Running Python linting..."
	flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
	black --check --diff .
	mypy . --ignore-missing-imports

format: ## Format code
	@echo "Formatting Python code..."
	black .
	@echo "Code formatting completed!"

security: ## Run security scans
	@echo "Running Trivy security scan..."
	trivy fs . --format table
	@echo "Checking for secrets..."
	trufflehog filesystem . --only-verified

audit: ## Run audit script (requires vCenter parameter)
ifndef VCENTER
	@echo "Error: VCENTER parameter is required"
	@echo "Usage: make audit VCENTER=vcenter.example.com"
	@exit 1
endif
	@echo "Running VMware vSphere 8 CIS audit against $(VCENTER)..."
	$(POWERSHELL) -Command "./cis-vsphere8-audit.ps1 -vCenter $(VCENTER) -ShowFailures"

audit-vm: ## Run VM-only audit (requires vCenter parameter)
ifndef VCENTER
	@echo "Error: VCENTER parameter is required"
	@echo "Usage: make audit-vm VCENTER=vcenter.example.com"
	@exit 1
endif
	@echo "Running VM audit against $(VCENTER)..."
	$(POWERSHELL) -Command "./cis-vsphere8-audit.ps1 -vCenter $(VCENTER) -Scope VM -ShowFailures"

audit-host: ## Run Host-only audit (requires vCenter parameter)
ifndef VCENTER
	@echo "Error: VCENTER parameter is required"
	@echo "Usage: make audit-host VCENTER=vcenter.example.com"
	@exit 1
endif
	@echo "Running Host audit against $(VCENTER)..."
	$(POWERSHELL) -Command "./cis-vsphere8-audit.ps1 -vCenter $(VCENTER) -Scope Host -ShowFailures"

audit-vc: ## Run vCenter-only audit (requires vCenter parameter)
ifndef VCENTER
	@echo "Error: VCENTER parameter is required"
	@echo "Usage: make audit-vc VCENTER=vcenter.example.com"
	@exit 1
endif
	@echo "Running vCenter audit against $(VCENTER)..."
	$(POWERSHELL) -Command "./cis-vsphere8-audit.ps1 -vCenter $(VCENTER) -Scope VC -ShowFailures"

validate: ## Validate all configuration files
	@echo "Validating YAML files..."
	yamllint .
	@echo "Validating Markdown files..."
	markdownlint **/*.md
	@echo "Validating JSON files..."
	find . -name "*.json" -exec python -m json.tool {} \; > /dev/null

clean: ## Clean temporary files
	@echo "Cleaning temporary files..."
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type f -name "*.log" -delete
	find . -type f -name ".DS_Store" -delete
	@echo "Cleanup completed!"

docs: ## Generate documentation
	@echo "Generating documentation..."
	@echo "Documentation available in README.md and docs/ directory"

release: ## Create a new release (requires VERSION parameter)
ifndef VERSION
	@echo "Error: VERSION parameter is required"
	@echo "Usage: make release VERSION=1.1.0"
	@exit 1
endif
	@echo "Creating release $(VERSION)..."
	git tag -a v$(VERSION) -m "Release version $(VERSION)"
	git push origin v$(VERSION)
	@echo "Release $(VERSION) created and pushed!"

check-deps: ## Check for dependency updates
	@echo "Checking Python dependencies..."
	$(PIP) list --outdated
	@echo "Checking PowerShell modules..."
	$(POWERSHELL) -Command "Get-InstalledModule | Where-Object {$_.Name -in @('VMware.PowerCLI', 'Pester', 'PSScriptAnalyzer')}"

ci: lint test security ## Run all CI checks locally
	@echo "All CI checks completed successfully!"