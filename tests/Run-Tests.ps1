#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Test runner script for VMware vSphere 8 CIS Compliance Audit Tool

.DESCRIPTION
    This script runs all tests for the audit tool using Pester framework.
    It supports different test types and generates coverage reports.

.PARAMETER TestType
    Type of tests to run: Unit, Integration, or All

.PARAMETER Coverage
    Generate code coverage report

.PARAMETER OutputFormat
    Output format for test results: NUnitXml, JUnitXml, or Console

.PARAMETER OutputPath
    Path for test result output file

.EXAMPLE
    .\Run-Tests.ps1
    Run all tests with default settings

.EXAMPLE
    .\Run-Tests.ps1 -TestType Unit -Coverage
    Run only unit tests with coverage report

.EXAMPLE
    .\Run-Tests.ps1 -OutputFormat JUnitXml -OutputPath ./test-results.xml
    Run tests and output results in JUnit XML format
#>

[CmdletBinding()]
param(
    [ValidateSet('Unit', 'Integration', 'All')]
    [string]$TestType = 'All',
    
    [switch]$Coverage,
    
    [ValidateSet('NUnitXml', 'JUnitXml', 'Console')]
    [string]$OutputFormat = 'Console',
    
    [string]$OutputPath = './TestResults.xml'
)

# Ensure we're in the correct directory
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptRoot
Set-Location $ProjectRoot

Write-Host "VMware vSphere 8 CIS Audit Tool - Test Runner" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check if Pester is available
if (-not (Get-Module -ListAvailable -Name Pester)) {
    Write-Error "Pester module is required. Please install it with: Install-Module -Name Pester -Force"
    exit 1
}

# Import Pester
Import-Module Pester -Force

# Determine test paths based on TestType
$TestPaths = switch ($TestType) {
    'Unit' { 
        @('./tests/Unit') 
    }
    'Integration' { 
        @('./tests/Integration') 
    }
    'All' { 
        @('./tests/Unit', './tests/Integration') 
    }
}

Write-Host "Test Configuration:" -ForegroundColor Yellow
Write-Host "  Test Type: $TestType" -ForegroundColor White
Write-Host "  Test Paths: $($TestPaths -join ', ')" -ForegroundColor White
Write-Host "  Coverage: $Coverage" -ForegroundColor White
Write-Host "  Output Format: $OutputFormat" -ForegroundColor White
if ($OutputFormat -ne 'Console') {
    Write-Host "  Output Path: $OutputPath" -ForegroundColor White
}
Write-Host ""

# Create Pester configuration
$PesterConfig = New-PesterConfiguration

# Set test paths
$PesterConfig.Run.Path = $TestPaths

# Set output verbosity
$PesterConfig.Output.Verbosity = 'Detailed'

# Configure code coverage if requested
if ($Coverage) {
    $PesterConfig.CodeCoverage.Enabled = $true
    $PesterConfig.CodeCoverage.Path = './cis-vsphere8-audit.ps1'
    $PesterConfig.CodeCoverage.OutputFormat = 'JaCoCo'
    $PesterConfig.CodeCoverage.OutputPath = './coverage.xml'
    Write-Host "Code coverage will be generated at: ./coverage.xml" -ForegroundColor Green
}

# Configure test results output
if ($OutputFormat -ne 'Console') {
    $PesterConfig.TestResult.Enabled = $true
    $PesterConfig.TestResult.OutputFormat = $OutputFormat
    $PesterConfig.TestResult.OutputPath = $OutputPath
    Write-Host "Test results will be saved to: $OutputPath" -ForegroundColor Green
}

# Set exit code behavior
$PesterConfig.Run.Exit = $true

Write-Host "Starting tests..." -ForegroundColor Green
Write-Host ""

# Run tests
try {
    $TestResults = Invoke-Pester -Configuration $PesterConfig
    
    # Display summary
    Write-Host ""
    Write-Host "Test Summary:" -ForegroundColor Yellow
    Write-Host "=============" -ForegroundColor Yellow
    Write-Host "  Total Tests: $($TestResults.TotalCount)" -ForegroundColor White
    Write-Host "  Passed: $($TestResults.PassedCount)" -ForegroundColor Green
    Write-Host "  Failed: $($TestResults.FailedCount)" -ForegroundColor Red
    Write-Host "  Skipped: $($TestResults.SkippedCount)" -ForegroundColor Yellow
    Write-Host "  Duration: $($TestResults.Duration)" -ForegroundColor White
    
    if ($Coverage -and $TestResults.CodeCoverage) {
        $CoveragePercent = [math]::Round(($TestResults.CodeCoverage.CoveragePercent), 2)
        Write-Host "  Code Coverage: $CoveragePercent%" -ForegroundColor Cyan
        
        if ($TestResults.CodeCoverage.MissedCommands.Count -gt 0) {
            Write-Host ""
            Write-Host "Missed Commands (not covered by tests):" -ForegroundColor Yellow
            foreach ($missed in $TestResults.CodeCoverage.MissedCommands | Select-Object -First 10) {
                Write-Host "  Line $($missed.Line): $($missed.Command)" -ForegroundColor Red
            }
            if ($TestResults.CodeCoverage.MissedCommands.Count -gt 10) {
                Write-Host "  ... and $($TestResults.CodeCoverage.MissedCommands.Count - 10) more" -ForegroundColor Red
            }
        }
    }
    
    Write-Host ""
    
    if ($TestResults.FailedCount -eq 0) {
        Write-Host "All tests passed! ✅" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Some tests failed! ❌" -ForegroundColor Red
        
        # Show failed test details
        if ($TestResults.Failed.Count -gt 0) {
            Write-Host ""
            Write-Host "Failed Tests:" -ForegroundColor Red
            foreach ($failed in $TestResults.Failed) {
                Write-Host "  ❌ $($failed.ExpandedName)" -ForegroundColor Red
                if ($failed.ErrorRecord) {
                    Write-Host "     $($failed.ErrorRecord.Exception.Message)" -ForegroundColor DarkRed
                }
            }
        }
        exit 1
    }
    
} catch {
    Write-Error "Test execution failed: $($_.Exception.Message)"
    exit 1
}# Updated 20251109_123817
# Updated Sun Nov  9 12:52:28 CET 2025
# Updated Sun Nov  9 12:56:25 CET 2025
