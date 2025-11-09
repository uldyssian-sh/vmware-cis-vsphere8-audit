<#
================================================================================
 Name     : cis-vsphere8-audit.ps1
 Purpose  : Read-only compliance checks for VMware vSphere 8 against common
            CIS / vSphere hardening items. Prints summary tables to console.
 Author   : uldyssian-sh
 Version  : 1.0
 Target   : VMware vSphere 8
================================================================================

 DISCLAIMER
 ----------
 This script is provided "as is", without any warranty of any kind.
 Use it at your own risk. You are solely responsible for reviewing,
 testing, and implementing it in your own environment.

 NOTES
 -----
 - Read-only. No configuration changes are performed.
 - Requires VMware.PowerCLI 13+.
================================================================================
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string]$vCenter,

  [ValidateSet('VM','Host','VC','All')]
  [string]$Scope = 'All',

  [switch]$ShowFailures    # also print per-object failed checks list
)

# --- Setup ----------------------------------------------------------------
if (-not (Get-Module -ListAvailable -Name VMware.PowerCLI)) {
  throw "VMware.PowerCLI module is required. Install-Module VMware.PowerCLI"
}
Import-Module VMware.PowerCLI -ErrorAction Stop | Out-Null
Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

Write-Host "Connecting to $vCenter ..." -ForegroundColor Cyan
$null = Connect-VIServer -Server $vCenter

# --- Helpers --------------------------------------------------------------
function New-Result { param($Object,$CheckId,$Passed,$Details)
  [PSCustomObject]@{
    Object   = $Object
    CheckId  = $CheckId
    Passed   = [bool]$Passed
    Details  = $Details
  }
}

function Get-AdvValue {
  param($VM, [string]$Name)
  try { ($VM | Get-AdvancedSetting -Name $Name -ErrorAction Stop).Value } catch { $null }
}
function Is-AdvTrue {
  param($VM,[string]$Name)
  $v = Get-AdvValue -VM $VM -Name $Name
  if ($null -eq $v) { return $false }
  try { return [bool]$v } catch { return $false }
}
function Is-AdvFalseOrMissing {
  param($VM,[string]$Name)
  $v = Get-AdvValue -VM $VM -Name $Name
  if ($null -eq $v) { return $true }
  try { return -not ([bool]$v) } catch { return $true }
}

# Helper: ESXCLI acceptance level (works even if Get-VMHostAcceptanceLevel is absent)
function Get-HostAcceptanceLevel {
  param([VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]$VMHost)
  try {
    # Prefer V2 esxcli
    $esxcli = Get-EsxCli -VMHost $VMHost -V2
    $res = $esxcli.software.acceptance.get.Invoke()
    return $res.AcceptanceLevel
  } catch {
    try {
      # Legacy esxcli
      $esxcli = Get-EsxCli -VMHost $VMHost
      return $esxcli.software.acceptance.get()
    } catch {
      return $null
    }
  }
}

# --- Checks (VM) ----------------------------------------------------------
function Invoke-VMChecks {
  $out = @()
  $vms = Get-VM
  foreach($vm in $vms){
    $cfg = $vm.ExtensionData.Config
    # Console data movement / Tools
    $copyDis    = Is-AdvTrue           $vm 'isolation.tools.copy.disable'
    $pasteDis   = Is-AdvTrue           $vm 'isolation.tools.paste.disable'
    $dndDis     = Is-AdvTrue           $vm 'isolation.tools.dnd.disable'
    $guiOff     = Is-AdvFalseOrMissing $vm 'isolation.tools.setGUIOptions.enable'
    $diskShrink = Is-AdvTrue           $vm 'isolation.tools.diskShrink.disable'
    $diskWiper  = Is-AdvTrue           $vm 'isolation.tools.diskWiper.disable'
    $devConnDis = Is-AdvTrue           $vm 'isolation.device.connectable.disable'
    $vncOn      = Is-AdvTrue           $vm 'RemoteDisplay.vnc.enabled'

    # Firmware / Secure Boot / vTPM
    $firmware   = $cfg.Firmware
    $secureBoot = $false; try { $secureBoot = [bool]$cfg.BootOptions.EfiSecureBootEnabled } catch {}
    $hasTPM = $false
    try { foreach($d in $cfg.Hardware.Device){ if($d -is [VMware.Vim.VirtualTPM]){ $hasTPM=$true; break } } } catch {}

    # Device hygiene (Connected CD, legacy devices)
    $serial=$false; $parallel=$false; $floppy=$false; $cdNow=$false; $cdOn=$false
    foreach($d in $cfg.Hardware.Device){
      switch -Regex ($d.GetType().Name){
        'VirtualSerialPort'   { $serial=$true }
        'VirtualParallelPort' { $parallel=$true }
        'VirtualFloppy'       { $floppy=$true }
        'VirtualCdrom'        {
          $now=[bool]$d.ConnectionState.Connected
          $on =[bool]($d.Connectable.Connected -or $d.Connectable.StartConnected)
          if($now){$cdNow=$true}; if($on){$cdOn=$true}
        }
      }
    }

    # Emit results
    $out += New-Result $vm.Name 'VM-01 Disable copy'                 $copyDis    "isolation.tools.copy.disable=$copyDis"
    $out += New-Result $vm.Name 'VM-02 Disable paste'                $pasteDis   "isolation.tools.paste.disable=$pasteDis"
    $out += New-Result $vm.Name 'VM-03 Disable drag&drop'            $dndDis     "isolation.tools.dnd.disable=$dndDis"
    $out += New-Result $vm.Name 'VM-04 Disable GUI options'          $guiOff     "isolation.tools.setGUIOptions.enable disabled/absent=$guiOff"
    $out += New-Result $vm.Name 'VM-05 Disable diskShrink'           $diskShrink "isolation.tools.diskShrink.disable=$diskShrink"
    $out += New-Result $vm.Name 'VM-06 Disable diskWiper'            $diskWiper  "isolation.tools.diskWiper.disable=$diskWiper"
    $out += New-Result $vm.Name 'VM-07 Disable device connect'       $devConnDis "isolation.device.connectable.disable=$devConnDis"
    $out += New-Result $vm.Name 'VM-08 Disable VNC console'          (-not $vncOn) "RemoteDisplay.vnc.enabled present=$vncOn"
    $out += New-Result $vm.Name 'VM-09 Use EFI firmware'             ($firmware -eq 'efi') "Firmware=$firmware"
    $out += New-Result $vm.Name 'VM-10 Enable Secure Boot (EFI)'     ($firmware -ne 'efi' -or $secureBoot) "SecureBoot=$secureBoot"
    $out += New-Result $vm.Name 'VM-11 Use vTPM when required'       $hasTPM     "vTPM=$hasTPM"
    $out += New-Result $vm.Name 'VM-12 CD/DVD not connected'         (-not $cdNow) "CD connected now=$cdNow"
    $out += New-Result $vm.Name 'VM-13 CD/DVD not connect on power'  (-not $cdOn)  "CD connect at power on=$cdOn"
    $out += New-Result $vm.Name 'VM-14 No legacy serial device'      (-not $serial)   "Serial present=$serial"
    $out += New-Result $vm.Name 'VM-15 No legacy parallel device'    (-not $parallel) "Parallel present=$parallel"
    $out += New-Result $vm.Name 'VM-16 No floppy device'             (-not $floppy)   "Floppy present=$floppy"
  }
  return $out
}

# --- Checks (ESXi Host) ---------------------------------------------------
function Invoke-HostChecks {
  $out = @()
  $hosts = Get-VMHost
  foreach($h in $hosts){
    # SSH service disabled & stopped
    $svc = Get-VMHostService -VMHost $h | Where-Object { $_.Key -eq 'TSM-SSH' }
    $sshStopped = -not $svc.Running
    $sshPolicyDisabled = -not $svc.Policy -or $svc.Policy -ne "on"
    # ESXi Shell disabled
    $tsm = Get-VMHostService -VMHost $h | Where-Object { $_.Key -eq 'TSM' }
    $shellStopped = -not $tsm.Running
    $shellPolicyDisabled = -not $tsm.Policy -or $tsm.Policy -ne "on"
    # NTP
    $ntpServers = Get-VMHostNtpServer -VMHost $h -ErrorAction SilentlyContinue
    $ntpd = Get-VMHostService -VMHost $h | Where-Object { $_.Key -eq 'ntpd' }
    $ntpConfigured = ($ntpServers -and $ntpServers.Count -gt 0)
    $ntpRunning = $ntpd.Running
    # Lockdown/DCUI
    $ld = $h.ExtensionData.Config.AdminDisabled
    $lockdown = [bool]$ld
    # Syslog configured
    $syslog = (Get-AdvancedSetting -Entity $h -Name 'Syslog.global.logHost' -ErrorAction SilentlyContinue).Value
    $syslogConfigured = -not [string]::IsNullOrWhiteSpace($syslog)
    # Acceptance level via ESXCLI (compatible replacement for Get-VMHostAcceptanceLevel)
    $acc = Get-HostAcceptanceLevel -VMHost $h
    $accOk = $acc -in @('PartnerSupported','VMwareAccepted')

    $out += New-Result $h.Name 'HST-01 SSH service disabled'        ($sshStopped -and $sshPolicyDisabled) "Running=$($svc.Running); Policy=$($svc.Policy)"
    $out += New-Result $h.Name 'HST-02 ESXi Shell disabled'         ($shellStopped -and $shellPolicyDisabled) "Running=$($tsm.Running); Policy=$($tsm.Policy)"
    $out += New-Result $h.Name 'HST-03 NTP configured'              $ntpConfigured "Servers=$($ntpServers -join ',')"
    $out += New-Result $h.Name 'HST-04 NTP running'                 $ntpRunning "ntpd.Running=$($ntpd.Running)"
    $out += New-Result $h.Name 'HST-05 Syslog configured'           $syslogConfigured "Syslog.global.logHost=$syslog"
    $out += New-Result $h.Name 'HST-06 Acceptance level trusted'    $accOk "AcceptanceLevel=$acc"
    $out += New-Result $h.Name 'HST-07 DCUI/Lockdown as policy'     $lockdown "AdminDisabled=$lockdown"
  }
  return $out
}

# --- Checks (vCenter) -----------------------------------------------------
function Invoke-VCChecks {
  $out = @()
  $server = $global:DefaultVIServer
  $name = if ($server) { $server.Name } else { 'vCenter' }
  try {
    $pp = Get-SsoPasswordPolicy
    $lp = Get-SsoLockoutPolicy
    $out += New-Result $name 'VC-01 Password min length >= 12'  ([int]$pp.MinimumLength -ge 12) "MinLength=$($pp.MinimumLength)"
    $out += New-Result $name 'VC-02 Password history >= 5'      ([int]$pp.MaximumPreviousPasswordCount -ge 5) "History=$($pp.MaximumPreviousPasswordCount)"
    $out += New-Result $name 'VC-03 Lockout threshold <= 5'     ([int]$lp.MaximumFailedAttempts -le 5) "MaxFailed=$($lp.MaximumFailedAttempts)"
    $out += New-Result $name 'VC-04 Lockout duration >= 15 min' ([int]$lp.AutoUnlockIntervalSec -ge 900) "AutoUnlockSec=$($lp.AutoUnlockIntervalSec)"
  } catch {
    $out += New-Result $name 'VC-01..04 SSO policy readable' $false "Could not read SSO policies: $($_.Exception.Message)"
  }
  try {
    $advs = Get-AdvancedSetting -Entity $server -Name 'config.log.level' -ErrorAction Stop
    $lvl = $advs.Value
    $out += New-Result $name 'VC-05 Logging level set' (-not [string]::IsNullOrWhiteSpace($lvl)) "config.log.level=$lvl"
  } catch {
    $out += New-Result $name 'VC-05 Logging level set' $false "No config.log.level"
  }
  return $out
}

# --- Execute scopes -------------------------------------------------------
$allResults = @()
if ($Scope -in @('VM','All'))   { $allResults += Invoke-VMChecks }
if ($Scope -in @('Host','All')) { $allResults += Invoke-HostChecks }
if ($Scope -in @('VC','All'))   { $allResults += Invoke-VCChecks }

# --- Summary --------------------------------------------------------------
if (-not $allResults -or $allResults.Count -eq 0) {
  Write-Warning "No results produced."
  return
}
$summary = $allResults | Group-Object CheckId | ForEach-Object {
  $pass = ($_.Group | Where-Object {$_.Passed}).Count
  $fail = ($_.Group | Where-Object {-not $_.Passed}).Count
  [PSCustomObject]@{
    CheckId = $_.Name
    Passed  = $pass
    Failed  = $fail
  }
} | Sort-Object CheckId

Write-Host ""
Write-Host "=== Compliance Summary (by Check) ===" -ForegroundColor Yellow
$summary | Format-Table -AutoSize

if ($ShowFailures) {
  Write-Host ""
  Write-Host "=== Failed Items (details) ===" -ForegroundColor Yellow
  $allResults | Where-Object {-not $_.Passed} |
    Sort-Object CheckId, Object |
    Format-Table -Property CheckId, Object, Details -AutoSize
}

Write-Host ""
Write-Host "Completed." -ForegroundColor Green
# Updated Sun Nov  9 12:52:28 CET 2025
# Updated Sun Nov  9 12:56:25 CET 2025
