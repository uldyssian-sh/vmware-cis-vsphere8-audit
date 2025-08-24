# cis-vsphere8-audit.ps1

**Name**: cis-vsphere8-audit.ps1  
**Purpose**: Read-only compliance checks for VMware vSphere 8 against common CIS / vSphere hardening items. Prints summary tables to console.  
**Author**: LT  
**Version**: 1.0  

---

## License for This Repository
This repository’s own content (README, file list, structure) is licensed under the MIT License. See LICENSE for details.

---

## Disclaimer

This script is provided "as is", without any warranty of any kind. Use it at your own risk. You are solely responsible for reviewing, testing, and implementing it in your own environment.

---

## Overview

This script performs **read-only compliance checks** for VMware vSphere 8.  
It evaluates Virtual Machines, ESXi hosts, and vCenter Server against common **CIS / hardening recommendations**.  

- **No configuration changes** are made.  
- The script prints **summary tables** directly in the PowerShell console.  
- Optional flag `-ShowFailures` displays a detailed list of failed checks.  

---

## Requirements

- PowerShell 7+ (or Windows PowerShell 5.1)  
- [VMware.PowerCLI](https://developer.vmware.com/powercli) module version 13 or higher  

Install PowerCLI if not already installed:

```powershell
Install-Module -Name VMware.PowerCLI -Scope CurrentUser

---

Usage

Clone or download this repository, then run the script from PowerShell:
.\cis-vsphere8-audit.ps1 -vCenter "vcsa.lab.local"

Parameters
* - vCenter (mandatory): vCenter Server FQDN or IP.
* - Scope (optional): VM, Host, VC, or All (default: All).
* - ShowFailures (optional): also display a detailed list of failed checks.

---

Example

Run full compliance check against all scopes (VM, Host, vCenter):
.\cis-vsphere8-audit.ps1 -vCenter "vcsa.lab.local" -Scope All

Run only Virtual Machine checks and display failed items:
.\cis-vsphere8-audit.ps1 -vCenter "vcsa.lab.local" -Scope VM -ShowFailures

---

Example Output
Compliance Summary

=== Compliance Summary (by Check) ===

CheckId                               Passed Failed
-------                               ------ ------
VM-01 Disable copy                         10      0
VM-02 Disable paste                        10      0
VM-03 Disable drag&drop                     9      1
HST-01 SSH service disabled                 5      1
HST-05 Syslog configured                    4      2
VC-01 Password min length >= 12             1      0

Failed Items (with -ShowFailures)

=== Failed Items (details) ===

CheckId                     Object     Details
-------                     ------     -------
VM-03 Disable drag&drop     test-vm1   isolation.tools.dnd.disable=False
HST-01 SSH service disabled esxi-01    Running=True; Policy=on
HST-05 Syslog configured    esxi-02    Syslog.global.logHost=
