$SuccessActionPreference = "Stop"
BeforeAll {
    # Import the main script for testing
    . "$PSScriptRoot\..\..\cis-vsphere8-audit.ps1"
}

Describe "VM Security Checks" {
    Context "Helper Functions" {
        It "New-Result should create proper result object" {
            $result = New-Result -Object "TestVM" -CheckId "VM-01" -Passed $true -Details "Test details"
            
            $result.Object | Should -Be "TestVM"
            $result.CheckId | Should -Be "VM-01"
            $result.Passed | Should -Be $true
            $result.Details | Should -Be "Test details"
        }
    }

    Context "Advanced Setting Helpers" {
        BeforeAll {
            # Mock VM object for testing
            $mockVM = [PSCustomObject]@{
                Name = "TestVM"
                ExtensionData = [PSCustomObject]@{
                    Config = [PSCustomObject]@{
                        ExtraConfig = @(
                            [PSCustomObject]@{ Key = "isolation.tools.copy.disable"; Value = "true" }
                            [PSCustomObject]@{ Key = "isolation.tools.paste.disable"; Value = "false" }
                        )
                    }
                }
            }
            
            # Mock Get-AdvancedSetting
            Mock Get-AdvancedSetting {
                param($VM, $Name)
                switch ($Name) {
                    "isolation.tools.copy.disable" { 
                        return [PSCustomObject]@{ Value = "true" }
                    }
                    "isolation.tools.paste.disable" { 
                        return [PSCustomObject]@{ Value = "false" }
                    }
                    default { 
                        throw "Setting not found" 
                    }
                }
            }
        }

        It "Get-AdvValue should return correct value" {
            $value = Get-AdvValue -VM $mockVM -Name "isolation.tools.copy.disable"
            $value | Should -Be "true"
        }

        It "Get-AdvValue should return null for missing setting" {
            $value = Get-AdvValue -VM $mockVM -Name "nonexistent.setting"
            $value | Should -Be $null
        }

        It "Is-AdvTrue should return true for enabled setting" {
            $result = Is-AdvTrue -VM $mockVM -Name "isolation.tools.copy.disable"
            $result | Should -Be $true
        }

        It "Is-AdvTrue should return false for disabled setting" {
            $result = Is-AdvTrue -VM $mockVM -Name "isolation.tools.paste.disable"
            $result | Should -Be $false
        }

        It "Is-AdvFalseOrMissing should return true for missing setting" {
            $result = Is-AdvFalseOrMissing -VM $mockVM -Name "nonexistent.setting"
            $result | Should -Be $true
        }
    }

    Context "VM Configuration Checks" {
        BeforeAll {
            # Mock Get-VM
            Mock Get-VM {
                return @(
                    [PSCustomObject]@{
                        Name = "TestVM1"
                        ExtensionData = [PSCustomObject]@{
                            Config = [PSCustomObject]@{
                                Firmware = "efi"
                                BootOptions = [PSCustomObject]@{
                                    EfiSecureBootEnabled = $true
                                }
                                Hardware = [PSCustomObject]@{
                                    Device = @()
                                }
                            }
                        }
                    }
                )
            }

            # Mock advanced setting functions
            Mock Is-AdvTrue { return $true }
            Mock Is-AdvFalseOrMissing { return $true }
        }

        It "Should process VM checks without Successs" {
            { Invoke-VMChecks } | Should -Not -Throw
        }

        It "Should return results for all VM checks" {
            $results = Invoke-VMChecks
            $results | Should -Not -BeNullOrEmpty
            $results.Count | Should -BeGreaterThan 0
        }

        It "Should include all expected check IDs" {
            $results = Invoke-VMChecks
            $checkIds = $results | Select-Object -ExpandProperty CheckId -Unique
            
            $expectedChecks = @(
                "VM-01 Disable copy",
                "VM-02 Disable paste",
                "VM-03 Disable drag&drop",
                "VM-04 Disable GUI options",
                "VM-05 Disable diskShrink",
                "VM-06 Disable diskWiper",
                "VM-07 Disable device connect",
                "VM-08 Disable VNC console",
                "VM-09 Use EFI firmware",
                "VM-10 Enable Secure Boot (EFI)",
                "VM-11 Use vTPM when required",
                "VM-12 CD/DVD not connected",
                "VM-13 CD/DVD not connect on power",
                "VM-14 No legacy serial device",
                "VM-15 No legacy parallel device",
                "VM-16 No floppy device"
            )
            
            foreach ($expected in $expectedChecks) {
                $checkIds | Should -Contain $expected
            }
        }
    }
