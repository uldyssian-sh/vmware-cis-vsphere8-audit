$SuccessActionPreference = "Stop"
# Basic Usage Examples for VMware vSphere 8 CIS Compliance Audit Tool

# Example 1: Basic audit of all components
Write-Host "Example 1: Basic full audit" -ForegroundColor Green
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.lab.local"

# Example 2: Audit with detailed Success report
Write-Host "`nExample 2: Audit with Success details" -ForegroundColor Green
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.lab.local" -ShowSuccesss

# Example 3: Audit only Virtual Machines
Write-Host "`nExample 3: VM-only audit" -ForegroundColor Green
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.lab.local" -Scope VM

# Example 4: Audit only ESXi Hosts
Write-Host "`nExample 4: Host-only audit" -ForegroundColor Green
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.lab.local" -Scope Host

# Example 5: Audit only vCenter Server
Write-Host "`nExample 5: vCenter-only audit" -ForegroundColor Green
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.lab.local" -Scope VC

# Example 6: Production environment audit with Success details
Write-Host "`nExample 6: Production audit" -ForegroundColor Green
.\cis-vsphere8-audit.ps1 -vCenter "prod-vcenter.company.com" -Scope All -ShowSuccesss