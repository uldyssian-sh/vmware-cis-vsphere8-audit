# Advanced Usage Examples for VMware vSphere 8 CIS Compliance Audit Tool

# Example 1: Audit with custom PowerCLI configuration
Write-Host "Example 1: Custom PowerCLI configuration" -ForegroundColor Green

# Configure PowerCLI for multiple servers and custom certificate handling
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Set-PowerCLIConfiguration -ParticipateInCEIP $false -Confirm:$false

# Run audit
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.lab.local" -ShowFailures

# Example 2: Audit multiple vCenter servers sequentially
Write-Host "`nExample 2: Multiple vCenter audit" -ForegroundColor Green

$vCenters = @("vcenter1.lab.local", "vcenter2.lab.local", "vcenter3.lab.local")

foreach ($vCenter in $vCenters) {
    Write-Host "`n--- Auditing $vCenter ---" -ForegroundColor Yellow
    try {
        .\cis-vsphere8-audit.ps1 -vCenter $vCenter -ShowFailures
        Write-Host "Audit completed for $vCenter" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to audit $vCenter`: $($_.Exception.Message)"
    }
    
    # Disconnect to clean up
    if ($global:DefaultVIServer) {
        Disconnect-VIServer -Server $global:DefaultVIServer -Confirm:$false -ErrorAction SilentlyContinue
    }
}

# Example 3: Audit with output redirection and logging
Write-Host "`nExample 3: Audit with logging" -ForegroundColor Green

$LogFile = "audit-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$vCenter = "vcenter.lab.local"

Write-Host "Starting audit of $vCenter - Log file: $LogFile"

# Redirect all output to log file while still showing on console
.\cis-vsphere8-audit.ps1 -vCenter $vCenter -ShowFailures | Tee-Object -FilePath $LogFile

Write-Host "Audit completed. Results saved to: $LogFile"

# Example 4: Scheduled audit with error handling
Write-Host "`nExample 4: Scheduled audit with error handling" -ForegroundColor Green

function Invoke-ScheduledAudit {
    param(
        [string]$VCenter,
        [string]$LogDirectory = ".\logs",
        [string]$EmailRecipient = $null
    )
    
    # Ensure log directory exists
    if (-not (Test-Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
    }
    
    $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $LogFile = Join-Path $LogDirectory "audit-$VCenter-$Timestamp.log"
    
    try {
        Write-Host "Starting scheduled audit of $VCenter"
        
        # Run audit and capture output
        $AuditOutput = .\cis-vsphere8-audit.ps1 -vCenter $VCenter -ShowFailures 2>&1
        
        # Save to log file
        $AuditOutput | Out-File -FilePath $LogFile -Encoding UTF8
        
        Write-Host "Audit completed successfully. Log: $LogFile" -ForegroundColor Green
        
        # Optional: Send email notification
        if ($EmailRecipient) {
            $Subject = "vSphere Audit Completed - $VCenter"
            $Body = "Audit of $VCenter completed successfully.`n`nLog file: $LogFile"
            # Send-MailMessage -To $EmailRecipient -Subject $Subject -Body $Body
            Write-Host "Email notification would be sent to: $EmailRecipient"
        }
        
    } catch {
        $ErrorMessage = $_.Exception.Message
        Write-Error "Audit failed for $VCenter`: $ErrorMessage"
        
        # Log error
        "ERROR: $ErrorMessage" | Out-File -FilePath $LogFile -Encoding UTF8
        
        # Optional: Send error notification
        if ($EmailRecipient) {
            $Subject = "vSphere Audit FAILED - $VCenter"
            $Body = "Audit of $VCenter failed with error:`n`n$ErrorMessage"
            # Send-MailMessage -To $EmailRecipient -Subject $Subject -Body $Body
            Write-Host "Error notification would be sent to: $EmailRecipient"
        }
    }
}

# Run scheduled audit
Invoke-ScheduledAudit -VCenter "vcenter.lab.local" -EmailRecipient "admin@company.com"

# Example 5: Audit with custom filtering and reporting
Write-Host "`nExample 5: Custom filtering and reporting" -ForegroundColor Green

function Invoke-CustomAudit {
    param(
        [string]$VCenter,
        [string[]]$IncludeChecks = @(),
        [string[]]$ExcludeChecks = @(),
        [string]$ReportFormat = "Console"
    )
    
    # This would require modifications to the main script to support filtering
    # For now, we'll demonstrate the concept
    
    Write-Host "Custom audit configuration:"
    Write-Host "  vCenter: $VCenter"
    Write-Host "  Include Checks: $($IncludeChecks -join ', ')"
    Write-Host "  Exclude Checks: $($ExcludeChecks -join ', ')"
    Write-Host "  Report Format: $ReportFormat"
    
    # Run standard audit (filtering would be implemented in main script)
    .\cis-vsphere8-audit.ps1 -vCenter $VCenter -ShowFailures
}

# Example custom audit focusing on VM security
Invoke-CustomAudit -VCenter "vcenter.lab.local" -IncludeChecks @("VM-01", "VM-02", "VM-03") -ReportFormat "JSON"

# Example 6: Audit with performance monitoring
Write-Host "`nExample 6: Performance monitoring" -ForegroundColor Green

$StopWatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "Starting performance-monitored audit..."

# Monitor memory usage before audit
$MemoryBefore = [System.GC]::GetTotalMemory($false) / 1MB

# Run audit
.\cis-vsphere8-audit.ps1 -vCenter "vcenter.lab.local"

# Monitor memory usage after audit
$MemoryAfter = [System.GC]::GetTotalMemory($true) / 1MB

$StopWatch.Stop()

Write-Host "`nPerformance Metrics:" -ForegroundColor Yellow
Write-Host "  Execution Time: $($StopWatch.Elapsed.TotalSeconds) seconds"
Write-Host "  Memory Before: $([math]::Round($MemoryBefore, 2)) MB"
Write-Host "  Memory After: $([math]::Round($MemoryAfter, 2)) MB"
Write-Host "  Memory Delta: $([math]::Round($MemoryAfter - $MemoryBefore, 2)) MB"

# Example 7: Audit with credential management
Write-Host "`nExample 7: Secure credential management" -ForegroundColor Green

function Invoke-SecureAudit {
    param(
        [string]$VCenter,
        [string]$CredentialFile = $null
    )
    
    if ($CredentialFile -and (Test-Path $CredentialFile)) {
        # Load encrypted credentials (this is a simplified example)
        Write-Host "Loading credentials from: $CredentialFile"
        # $Credential = Import-Clixml $CredentialFile
        # Connect-VIServer -Server $VCenter -Credential $Credential
    } else {
        Write-Host "Using current user credentials or prompting for credentials"
    }
    
    # Run audit
    .\cis-vsphere8-audit.ps1 -vCenter $VCenter -ShowFailures
}

# Example secure audit
Invoke-SecureAudit -VCenter "vcenter.lab.local" -CredentialFile ".\secure-creds.xml"

Write-Host "`nAll advanced examples completed!" -ForegroundColor Green# Updated Sun Nov  9 12:52:28 CET 2025
