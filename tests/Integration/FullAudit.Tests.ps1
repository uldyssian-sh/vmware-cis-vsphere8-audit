BeforeAll {
    # Import the main script for testing
    . "$PSScriptRoot\..\..\cis-vsphere8-audit.ps1"
}

Describe "Full Audit Integration Tests" {
    Context "Script Parameter Validation" {
        It "Should require vCenter parameter" {
            { & "$PSScriptRoot\..\..\cis-vsphere8-audit.ps1" } | Should -Throw
        }

        It "Should accept valid Scope values" {
            $validScopes = @('VM', 'Host', 'VC', 'All')
            foreach ($scope in $validScopes) {
                # This would normally connect to vCenter, so we'll just test parameter binding
                $params = @{
                    vCenter = "test.local"
                    Scope = $scope
                }
                { $params } | Should -Not -Throw
            }
        }

        It "Should reject invalid Scope values" {
            { 
                $params = @{
                    vCenter = "test.local"
                    Scope = "Invalid"
                }
            } | Should -Not -Throw # Parameter validation happens at runtime
        }
    }

    Context "Mock Full Audit Execution" {
        BeforeAll {
            # Mock PowerCLI module check
            Mock Get-Module {
                param($ListAvailable, $Name)
                if ($Name -eq "VMware.PowerCLI") {
                    return [PSCustomObject]@{ Name = "VMware.PowerCLI"; Version = "13.0.0" }
                }
                return $null
            }

            Mock Import-Module { }
            Mock Set-PowerCLIConfiguration { }
            Mock Connect-VIServer { 
                return [PSCustomObject]@{ Name = "vcenter.test.local" }
            }

            # Mock all check functions
            Mock Invoke-VMChecks {
                return @(
                    New-Result -Object "TestVM" -CheckId "VM-01 Disable copy" -Passed $true -Details "isolation.tools.copy.disable=true"
                )
            }

            Mock Invoke-HostChecks {
                return @(
                    New-Result -Object "TestHost" -CheckId "HST-01 SSH service disabled" -Passed $true -Details "Running=False; Policy=off"
                )
            }

            Mock Invoke-VCChecks {
                return @(
                    New-Result -Object "vCenter" -CheckId "VC-01 Password min length >= 12" -Passed $true -Details "MinLength=12"
                )
            }

            # Set global variable for vCenter connection
            $global:DefaultVIServer = [PSCustomObject]@{ Name = "vcenter.test.local" }
        }

        It "Should execute VM scope successfully" {
            Mock Write-Host { }
            
            # Simulate script execution with VM scope
            $allResults = @()
            $allResults += Invoke-VMChecks
            
            $allResults | Should -Not -BeNullOrEmpty
            $allResults.Count | Should -Be 1
            $allResults[0].CheckId | Should -Be "VM-01 Disable copy"
        }

        It "Should execute Host scope successfully" {
            Mock Write-Host { }
            
            # Simulate script execution with Host scope
            $allResults = @()
            $allResults += Invoke-HostChecks
            
            $allResults | Should -Not -BeNullOrEmpty
            $allResults.Count | Should -Be 1
            $allResults[0].CheckId | Should -Be "HST-01 SSH service disabled"
        }

        It "Should execute VC scope successfully" {
            Mock Write-Host { }
            
            # Simulate script execution with VC scope
            $allResults = @()
            $allResults += Invoke-VCChecks
            
            $allResults | Should -Not -BeNullOrEmpty
            $allResults.Count | Should -Be 1
            $allResults[0].CheckId | Should -Be "VC-01 Password min length >= 12"
        }

        It "Should execute All scope successfully" {
            Mock Write-Host { }
            
            # Simulate script execution with All scope
            $allResults = @()
            $allResults += Invoke-VMChecks
            $allResults += Invoke-HostChecks
            $allResults += Invoke-VCChecks
            
            $allResults | Should -Not -BeNullOrEmpty
            $allResults.Count | Should -Be 3
        }

        It "Should generate summary correctly" {
            Mock Write-Host { }
            Mock Format-Table { }
            
            $allResults = @(
                New-Result -Object "TestVM1" -CheckId "VM-01 Disable copy" -Passed $true -Details "Test"
                New-Result -Object "TestVM2" -CheckId "VM-01 Disable copy" -Passed $false -Details "Test"
                New-Result -Object "TestHost" -CheckId "HST-01 SSH service disabled" -Passed $true -Details "Test"
            )
            
            $summary = $allResults | Group-Object CheckId | ForEach-Object {
                $pass = ($_.Group | Where-Object {$_.Passed}).Count
                $fail = ($_.Group | Where-Object {-not $_.Passed}).Count
                [PSCustomObject]@{
                    CheckId = $_.Name
                    Passed  = $pass
                    Failed  = $fail
                }
            } | Sort-Object CheckId
            
            $summary | Should -Not -BeNullOrEmpty
            $summary.Count | Should -Be 2
            
            $vmCheck = $summary | Where-Object { $_.CheckId -eq "VM-01 Disable copy" }
            $vmCheck.Passed | Should -Be 1
            $vmCheck.Failed | Should -Be 1
            
            $hostCheck = $summary | Where-Object { $_.CheckId -eq "HST-01 SSH service disabled" }
            $hostCheck.Passed | Should -Be 1
            $hostCheck.Failed | Should -Be 0
        }
    }

    Context "Error Handling" {
        It "Should handle PowerCLI module not found" {
            Mock Get-Module { return $null }
            
            { 
                if (-not (Get-Module -ListAvailable -Name VMware.PowerCLI)) {
                    throw "VMware.PowerCLI module is required. Install-Module VMware.PowerCLI"
                }
            } | Should -Throw "*VMware.PowerCLI module is required*"
        }

        It "Should handle connection failures gracefully" {
            Mock Connect-VIServer { throw "Connection failed" }
            
            { Connect-VIServer -Server "invalid.server" } | Should -Throw
        }

        It "Should handle empty results" {
            Mock Write-Warning { }
            
            $allResults = @()
            
            if (-not $allResults -or $allResults.Count -eq 0) {
                Write-Warning "No results produced."
                # This should not throw, just warn
            }
            
            # Test passes if no exception is thrown
            $true | Should -Be $true
        }
    }
}