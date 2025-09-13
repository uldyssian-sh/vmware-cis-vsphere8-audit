BeforeAll {
    # Import the main script for testing
    . "$PSScriptRoot\..\..\cis-vsphere8-audit.ps1"
}

Describe "Host Security Checks" {
    Context "Host Configuration Checks" {
        BeforeAll {
            # Mock Get-VMHost
            Mock Get-VMHost {
                return @(
                    [PSCustomObject]@{
                        Name = "esxi-01.lab.local"
                        ExtensionData = [PSCustomObject]@{
                            Config = [PSCustomObject]@{
                                AdminDisabled = $true
                            }
                        }
                    }
                )
            }

            # Mock Get-VMHostService
            Mock Get-VMHostService {
                param($VMHost)
                return @(
                    [PSCustomObject]@{
                        Key = "TSM-SSH"
                        Running = $false
                        Policy = "off"
                    },
                    [PSCustomObject]@{
                        Key = "TSM"
                        Running = $false
                        Policy = "off"
                    },
                    [PSCustomObject]@{
                        Key = "ntpd"
                        Running = $true
                        Policy = "on"
                    }
                )
            }

            # Mock Get-VMHostNtpServer
            Mock Get-VMHostNtpServer {
                return @("pool.ntp.org", "time.nist.gov")
            }

            # Mock Get-AdvancedSetting
            Mock Get-AdvancedSetting {
                param($Entity, $Name)
                if ($Name -eq "Syslog.global.logHost") {
                    return [PSCustomObject]@{ Value = "syslog.lab.local:514" }
                }
                return $null
            }

            # Mock Get-HostAcceptanceLevel
            Mock Get-HostAcceptanceLevel {
                return "VMwareAccepted"
            }
        }

        It "Should process host checks without errors" {
            { Invoke-HostChecks } | Should -Not -Throw
        }

        It "Should return results for all host checks" {
            $results = Invoke-HostChecks
            $results | Should -Not -BeNullOrEmpty
            $results.Count | Should -BeGreaterThan 0
        }

        It "Should include all expected check IDs" {
            $results = Invoke-HostChecks
            $checkIds = $results | Select-Object -ExpandProperty CheckId -Unique
            
            $expectedChecks = @(
                "HST-01 SSH service disabled",
                "HST-02 ESXi Shell disabled",
                "HST-03 NTP configured",
                "HST-04 NTP running",
                "HST-05 Syslog configured",
                "HST-06 Acceptance level trusted",
                "HST-07 DCUI/Lockdown as policy"
            )
            
            foreach ($expected in $expectedChecks) {
                $checkIds | Should -Contain $expected
            }
        }

        It "Should correctly identify SSH service status" {
            $results = Invoke-HostChecks
            $sshCheck = $results | Where-Object { $_.CheckId -eq "HST-01 SSH service disabled" }
            $sshCheck.Passed | Should -Be $true
        }

        It "Should correctly identify NTP configuration" {
            $results = Invoke-HostChecks
            $ntpCheck = $results | Where-Object { $_.CheckId -eq "HST-03 NTP configured" }
            $ntpCheck.Passed | Should -Be $true
        }

        It "Should correctly identify syslog configuration" {
            $results = Invoke-HostChecks
            $syslogCheck = $results | Where-Object { $_.CheckId -eq "HST-05 Syslog configured" }
            $syslogCheck.Passed | Should -Be $true
        }
    }

    Context "Get-HostAcceptanceLevel Function" {
        BeforeAll {
            # Mock successful esxcli v2
            Mock Get-EsxCli {
                param($VMHost, $V2)
                if ($V2) {
                    return [PSCustomObject]@{
                        software = [PSCustomObject]@{
                            acceptance = [PSCustomObject]@{
                                get = [PSCustomObject]@{
                                    Invoke = { 
                                        return [PSCustomObject]@{ AcceptanceLevel = "VMwareAccepted" }
                                    }
                                }
                            }
                        }
                    }
                }
                return $null
            }
        }

        It "Should return acceptance level using esxcli v2" {
            $mockHost = [PSCustomObject]@{ Name = "test-host" }
            $level = Get-HostAcceptanceLevel -VMHost $mockHost
            $level | Should -Be "VMwareAccepted"
        }
    }
}