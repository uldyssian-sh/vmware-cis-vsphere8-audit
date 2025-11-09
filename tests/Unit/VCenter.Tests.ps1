BeforeAll {
    # Import the main script for testing
    . "$PSScriptRoot\..\..\cis-vsphere8-audit.ps1"
}

Describe "vCenter Security Checks" {
    Context "vCenter Configuration Checks" {
        BeforeAll {
            # Mock global variable
            $global:DefaultVIServer = [PSCustomObject]@{
                Name = "vcenter.lab.local"
            }

            # Mock Get-SsoPasswordPolicy
            Mock Get-SsoPasswordPolicy {
                return [PSCustomObject]@{
                    MinimumLength = 12
                    MaximumPreviousPasswordCount = 5
                }
            }

            # Mock Get-SsoLockoutPolicy
            Mock Get-SsoLockoutPolicy {
                return [PSCustomObject]@{
                    MaximumFailedAttempts = 3
                    AutoUnlockIntervalSec = 900
                }
            }

            # Mock Get-AdvancedSetting for vCenter
            Mock Get-AdvancedSetting {
                param($Entity, $Name)
                if ($Name -eq "config.log.level") {
                    return [PSCustomObject]@{ Value = "info" }
                }
                return $null
            }
        }

        It "Should process vCenter checks without errors" {
            { Invoke-VCChecks } | Should -Not -Throw
        }

        It "Should return results for all vCenter checks" {
            $results = Invoke-VCChecks
            $results | Should -Not -BeNullOrEmpty
            $results.Count | Should -BeGreaterThan 0
        }

        It "Should include all expected check IDs" {
            $results = Invoke-VCChecks
            $checkIds = $results | Select-Object -ExpandProperty CheckId -Unique
            
            $expectedChecks = @(
                "VC-01 Password min length >= 12",
                "VC-02 Password history >= 5",
                "VC-03 Lockout threshold <= 5",
                "VC-04 Lockout duration >= 15 min",
                "VC-05 Logging level set"
            )
            
            foreach ($expected in $expectedChecks) {
                $checkIds | Should -Contain $expected
            }
        }

        It "Should correctly validate password minimum length" {
            $results = Invoke-VCChecks
            $passwordCheck = $results | Where-Object { $_.CheckId -eq "VC-01 Password min length >= 12" }
            $passwordCheck.Passed | Should -Be $true
        }

        It "Should correctly validate password history" {
            $results = Invoke-VCChecks
            $historyCheck = $results | Where-Object { $_.CheckId -eq "VC-02 Password history >= 5" }
            $historyCheck.Passed | Should -Be $true
        }

        It "Should correctly validate lockout threshold" {
            $results = Invoke-VCChecks
            $lockoutCheck = $results | Where-Object { $_.CheckId -eq "VC-03 Lockout threshold <= 5" }
            $lockoutCheck.Passed | Should -Be $true
        }

        It "Should correctly validate lockout duration" {
            $results = Invoke-VCChecks
            $durationCheck = $results | Where-Object { $_.CheckId -eq "VC-04 Lockout duration >= 15 min" }
            $durationCheck.Passed | Should -Be $true
        }

        It "Should correctly validate logging level" {
            $results = Invoke-VCChecks
            $loggingCheck = $results | Where-Object { $_.CheckId -eq "VC-05 Logging level set" }
            $loggingCheck.Passed | Should -Be $true
        }
    }

    Context "Error Handling" {
        BeforeAll {
            $global:DefaultVIServer = [PSCustomObject]@{
                Name = "vcenter.lab.local"
            }

            # Mock failed SSO policy retrieval
            Mock Get-SsoPasswordPolicy {
                throw "Access denied"
            }

            Mock Get-SsoLockoutPolicy {
                throw "Access denied"
            }

            Mock Get-AdvancedSetting {
                throw "Setting not found"
            }
        }

        It "Should handle SSO policy errors gracefully" {
            $results = Invoke-VCChecks
            $errorCheck = $results | Where-Object { $_.CheckId -like "VC-01..04*" }
            $errorCheck.Passed | Should -Be $false
            $errorCheck.Details | Should -Match "Could not read SSO policies"
        }

        It "Should handle advanced setting errors gracefully" {
            $results = Invoke-VCChecks
            $loggingCheck = $results | Where-Object { $_.CheckId -eq "VC-05 Logging level set" }
            $loggingCheck.Passed | Should -Be $false
            $loggingCheck.Details | Should -Match "No config.log.level"
        }
    }
}# Updated 20251109_123817
# Updated Sun Nov  9 12:52:28 CET 2025
