# Mock Data and Helper Functions for Testing

# Mock VM objects
function New-MockVM {
    param(
        [string]$Name = "MockVM",
        [string]$Firmware = "efi",
        [bool]$SecureBoot = $true,
        [hashtable]$AdvancedSettings = @{}
    )
    
    $mockVM = [PSCustomObject]@{
        Name = $Name
        ExtensionData = [PSCustomObject]@{
            Config = [PSCustomObject]@{
                Firmware = $Firmware
                BootOptions = [PSCustomObject]@{
                    EfiSecureBootEnabled = $SecureBoot
                }
                Hardware = [PSCustomObject]@{
                    Device = @()
                }
                ExtraConfig = @()
            }
        }
    }
    
    # Add advanced settings
    foreach ($key in $AdvancedSettings.Keys) {
        $mockVM.ExtensionData.Config.ExtraConfig += [PSCustomObject]@{
            Key = $key
            Value = $AdvancedSettings[$key]
        }
    }
    
    return $mockVM
}

# Mock VMHost objects
function New-MockVMHost {
    param(
        [string]$Name = "MockHost",
        [bool]$AdminDisabled = $false,
        [hashtable]$Services = @{},
        [string[]]$NtpServers = @(),
        [string]$SyslogHost = "",
        [string]$AcceptanceLevel = "VMwareAccepted"
    )
    
    $mockHost = [PSCustomObject]@{
        Name = $Name
        ExtensionData = [PSCustomObject]@{
            Config = [PSCustomObject]@{
                AdminDisabled = $AdminDisabled
            }
        }
    }
    
    return $mockHost
}

# Mock VMHost Service objects
function New-MockVMHostService {
    param(
        [string]$Key,
        [bool]$Running = $false,
        [string]$Policy = "off"
    )
    
    return [PSCustomObject]@{
        Key = $Key
        Running = $Running
        Policy = $Policy
    }
}

# Mock Advanced Setting objects
function New-MockAdvancedSetting {
    param(
        [string]$Name,
        [string]$Value
    )
    
    return [PSCustomObject]@{
        Name = $Name
        Value = $Value
    }
}

# Mock SSO Password Policy
function New-MockSsoPasswordPolicy {
    param(
        [int]$MinimumLength = 8,
        [int]$MaximumPreviousPasswordCount = 0
    )
    
    return [PSCustomObject]@{
        MinimumLength = $MinimumLength
        MaximumPreviousPasswordCount = $MaximumPreviousPasswordCount
    }
}

# Mock SSO Lockout Policy
function New-MockSsoLockoutPolicy {
    param(
        [int]$MaximumFailedAttempts = 5,
        [int]$AutoUnlockIntervalSec = 300
    )
    
    return [PSCustomObject]@{
        MaximumFailedAttempts = $MaximumFailedAttempts
        AutoUnlockIntervalSec = $AutoUnlockIntervalSec
    }
}

# Mock VI Server connection
function New-MockVIServer {
    param(
        [string]$Name = "vcenter.test.local"
    )
    
    return [PSCustomObject]@{
        Name = $Name
        IsConnected = $true
        Version = "8.0.0"
    }
}

# Test data sets for different scenarios
$script:TestDataSets = @{
    # Compliant VM configuration
    CompliantVM = @{
        Name = "CompliantVM"
        AdvancedSettings = @{
            "isolation.tools.copy.disable" = "true"
            "isolation.tools.paste.disable" = "true"
            "isolation.tools.dnd.disable" = "true"
            "isolation.tools.setGUIOptions.enable" = "false"
            "isolation.tools.diskShrink.disable" = "true"
            "isolation.tools.diskWiper.disable" = "true"
            "isolation.device.connectable.disable" = "true"
        }
        Firmware = "efi"
        SecureBoot = $true
    }
    
    # Non-compliant VM configuration
    NonCompliantVM = @{
        Name = "NonCompliantVM"
        AdvancedSettings = @{
            "isolation.tools.copy.disable" = "false"
            "isolation.tools.paste.disable" = "false"
            "isolation.tools.dnd.disable" = "false"
            "RemoteDisplay.vnc.enabled" = "true"
        }
        Firmware = "bios"
        SecureBoot = $false
    }
    
    # Compliant ESXi host configuration
    CompliantHost = @{
        Name = "CompliantHost"
        AdminDisabled = $true
        Services = @{
            "TSM-SSH" = @{ Running = $false; Policy = "off" }
            "TSM" = @{ Running = $false; Policy = "off" }
            "ntpd" = @{ Running = $true; Policy = "on" }
        }
        NtpServers = @("pool.ntp.org", "time.nist.gov")
        SyslogHost = "syslog.lab.local:514"
        AcceptanceLevel = "VMwareAccepted"
    }
    
    # Non-compliant ESXi host configuration
    NonCompliantHost = @{
        Name = "NonCompliantHost"
        AdminDisabled = $false
        Services = @{
            "TSM-SSH" = @{ Running = $true; Policy = "on" }
            "TSM" = @{ Running = $true; Policy = "on" }
            "ntpd" = @{ Running = $false; Policy = "off" }
        }
        NtpServers = @()
        SyslogHost = ""
        AcceptanceLevel = "CommunitySupported"
    }
    
    # Compliant vCenter configuration
    CompliantVC = @{
        PasswordPolicy = @{
            MinimumLength = 12
            MaximumPreviousPasswordCount = 5
        }
        LockoutPolicy = @{
            MaximumFailedAttempts = 3
            AutoUnlockIntervalSec = 900
        }
        LogLevel = "info"
    }
    
    # Non-compliant vCenter configuration
    NonCompliantVC = @{
        PasswordPolicy = @{
            MinimumLength = 6
            MaximumPreviousPasswordCount = 0
        }
        LockoutPolicy = @{
            MaximumFailedAttempts = 10
            AutoUnlockIntervalSec = 60
        }
        LogLevel = ""
    }
}

# Helper function to get test data
function Get-TestData {
    param(
        [string]$DataSetName
    )
    
    return $script:TestDataSets[$DataSetName]
}

# Helper function to create mock environment
function Initialize-MockEnvironment {
    param(
        [string]$Scenario = "Mixed"
    )
    
    switch ($Scenario) {
        "AllCompliant" {
            # Setup mocks for fully compliant environment
            Mock Get-VM { 
                return New-MockVM @(Get-TestData "CompliantVM")
            }
            Mock Get-VMHost {
                return New-MockVMHost @(Get-TestData "CompliantHost")
            }
        }
        "AllNonCompliant" {
            # Setup mocks for non-compliant environment
            Mock Get-VM { 
                return New-MockVM @(Get-TestData "NonCompliantVM")
            }
            Mock Get-VMHost {
                return New-MockVMHost @(Get-TestData "NonCompliantHost")
            }
        }
        "Mixed" {
            # Setup mocks for mixed environment
            Mock Get-VM { 
                return @(
                    New-MockVM @(Get-TestData "CompliantVM")
                    New-MockVM @(Get-TestData "NonCompliantVM")
                )
            }
            Mock Get-VMHost {
                return @(
                    New-MockVMHost @(Get-TestData "CompliantHost")
                    New-MockVMHost @(Get-TestData "NonCompliantHost")
                )
            }
        }
    }
}

# Export functions for use in tests
Export-ModuleMember -Function @(
    'New-MockVM',
    'New-MockVMHost', 
    'New-MockVMHostService',
    'New-MockAdvancedSetting',
    'New-MockSsoPasswordPolicy',
    'New-MockSsoLockoutPolicy',
    'New-MockVIServer',
    'Get-TestData',
    'Initialize-MockEnvironment'
)# Updated 20251109_123817
# Updated Sun Nov  9 12:52:28 CET 2025
