#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Aggregates multiple AppCAT report files into a single consolidated report.

.DESCRIPTION
    This script merges multiple AppCAT JSON report files from the app-modernization folder.
    It combines projects, deduplicates rules, and recalculates summary statistics.

.PARAMETER ReportFolder
    Path to the folder containing report files. Defaults to app-modernization folder.

.PARAMETER OutputFile
    Path for the aggregated output file. Defaults to aggregated-report.json in the report folder.

.EXAMPLE
    .\aggregate.ps1
    .\aggregate.ps1 -ReportFolder "c:\path\to\reports" -OutputFile "c:\output\aggregated.json"
#>

param(
    [Parameter()]
    [string]$ReportFolder = (Join-Path $PSScriptRoot "..\..\..\app-modernization"),
    
    [Parameter()]
    [string]$OutputFile = ""
)

# Ensure the report folder exists
if (-not (Test-Path $ReportFolder)) {
    Write-Error "Report folder not found: $ReportFolder"
    exit 1
}

# Set default output file if not specified
if ([string]::IsNullOrEmpty($OutputFile)) {
    $OutputFile = Join-Path $ReportFolder "aggregated-report.json"
}

Write-Host "Aggregating reports from: $ReportFolder" -ForegroundColor Cyan
Write-Host "Output file: $OutputFile" -ForegroundColor Cyan

# Find all JSON report files
$reportFiles = Get-ChildItem -Path $ReportFolder -Filter "*-report.json" | 
    Where-Object { $_.Name -ne "aggregated-report.json" }

if ($reportFiles.Count -eq 0) {
    Write-Error "No report files found in $ReportFolder"
    exit 1
}

Write-Host "Found $($reportFiles.Count) report file(s) to aggregate" -ForegroundColor Green

# Initialize aggregated report structure
$aggregatedReport = $null
$allProjects = @()
$allRules = @{}
$totalIncidents = 0

# Process each report file
foreach ($file in $reportFiles) {
    Write-Host "Processing: $($file.Name)" -ForegroundColor Yellow
    
    try {
        $report = Get-Content $file.FullName -Raw | ConvertFrom-Json
        
        # Initialize aggregated report with first file's metadata
        if ($null -eq $aggregatedReport) {
            $aggregatedReport = [PSCustomObject]@{
                version = $report.version
                producer = $report.producer
                metadata = $report.metadata
                summary = [PSCustomObject]@{
                    totalProjects = 0
                    totalIssues = 0
                    totalIncidents = 0
                    totalEffort = 0
                    charts = [PSCustomObject]@{
                        severity = [PSCustomObject]@{
                            mandatory = 0
                            optional = 0
                            potential = 0
                            information = 0
                        }
                        category = [PSCustomObject]@{}
                    }
                }
                projects = @()
                rules = [PSCustomObject]@{}
            }
        }
        
        # Add projects from current report
        foreach ($project in $report.projects) {
            $allProjects += $project
        }
        
        # Merge rules (deduplicate by rule ID)
        $report.rules.PSObject.Properties | ForEach-Object {
            $ruleId = $_.Name
            $ruleData = $_.Value
            
            if (-not $allRules.ContainsKey($ruleId)) {
                $allRules[$ruleId] = $ruleData
            }
        }
        
        # Count incidents
        foreach ($project in $report.projects) {
            $totalIncidents += $project.incidents.Count
        }
        
        Write-Host "  - Projects: $($report.projects.Count)" -ForegroundColor Gray
        Write-Host "  - Rules: $($report.rules.PSObject.Properties.Count)" -ForegroundColor Gray
        Write-Host "  - Incidents: $($report.summary.totalIncidents)" -ForegroundColor Gray
        
    } catch {
        Write-Error "Failed to process $($file.Name): $_"
        continue
    }
}

# Assign aggregated projects
$aggregatedReport.projects = $allProjects

# Convert rules hashtable to PSCustomObject
$rulesObject = [PSCustomObject]@{}
$allRules.GetEnumerator() | ForEach-Object {
    Add-Member -InputObject $rulesObject -MemberType NoteProperty -Name $_.Key -Value $_.Value
}
$aggregatedReport.rules = $rulesObject

# Recalculate summary statistics
Write-Host "`nRecalculating summary statistics..." -ForegroundColor Cyan

$aggregatedReport.summary.totalProjects = $allProjects.Count
$aggregatedReport.summary.totalIssues = 0
$aggregatedReport.summary.totalIncidents = 0
$aggregatedReport.summary.totalEffort = 0

# Initialize category tracking
$categoryTotals = @{}

# Calculate totals from projects
foreach ($project in $allProjects) {
    $aggregatedReport.summary.totalIssues += $project.issues
    $aggregatedReport.summary.totalEffort += $project.storyPoints
    
    # Count incidents and aggregate by severity and category
    foreach ($incident in $project.incidents) {
        $aggregatedReport.summary.totalIncidents++
        
        # Get severity from the first target (they should all be the same)
        $target = $incident.targets.PSObject.Properties | Select-Object -First 1
        if ($target) {
            $severity = $target.Value.severity
            
            switch ($severity) {
                "mandatory" { $aggregatedReport.summary.charts.severity.mandatory++ }
                "optional" { $aggregatedReport.summary.charts.severity.optional++ }
                "potential" { $aggregatedReport.summary.charts.severity.potential++ }
                "information" { $aggregatedReport.summary.charts.severity.information++ }
            }
        }
        
        # Find the rule to get category
        $rule = $allRules[$incident.ruleId]
        if ($rule -and $rule.labels) {
            $categoryLabel = $rule.labels | Where-Object { $_ -match "^category=" } | Select-Object -First 1
            if ($categoryLabel) {
                $category = $categoryLabel -replace "^category=", ""
                if (-not $categoryTotals.ContainsKey($category)) {
                    $categoryTotals[$category] = 0
                }
                $categoryTotals[$category]++
            }
        }
    }
}

# Add category totals to summary
$categoryTotals.GetEnumerator() | ForEach-Object {
    Add-Member -InputObject $aggregatedReport.summary.charts.category -MemberType NoteProperty -Name $_.Key -Value $_.Value -Force
}

# Save aggregated report
Write-Host "`nSaving aggregated report..." -ForegroundColor Cyan

# Ensure output directory exists
$outputDir = Split-Path -Path $OutputFile -Parent
if (-not (Test-Path $outputDir)) {
    Write-Host "Creating output directory: $outputDir" -ForegroundColor Yellow
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
}

try {
    $aggregatedReport | ConvertTo-Json -Depth 100 | Set-Content -Path $OutputFile -Encoding UTF8
    Write-Host "Aggregated report saved to: $OutputFile" -ForegroundColor Green
    
    # Display summary
    Write-Host "`nAggregation Summary:" -ForegroundColor Cyan
    Write-Host "  Total Projects: $($aggregatedReport.summary.totalProjects)" -ForegroundColor White
    Write-Host "  Total Issues: $($aggregatedReport.summary.totalIssues)" -ForegroundColor White
    Write-Host "  Total Incidents: $($aggregatedReport.summary.totalIncidents)" -ForegroundColor White
    Write-Host "  Total Effort: $($aggregatedReport.summary.totalEffort)" -ForegroundColor White
    Write-Host "  Unique Rules: $($allRules.Count)" -ForegroundColor White
    Write-Host "`n  Severity Distribution:" -ForegroundColor Yellow
    Write-Host "    Mandatory: $($aggregatedReport.summary.charts.severity.mandatory)" -ForegroundColor White
    Write-Host "    Optional: $($aggregatedReport.summary.charts.severity.optional)" -ForegroundColor White
    Write-Host "    Potential: $($aggregatedReport.summary.charts.severity.potential)" -ForegroundColor White
    Write-Host "    Information: $($aggregatedReport.summary.charts.severity.information)" -ForegroundColor White
    
} catch {
    Write-Error "Failed to save aggregated report: $_"
    exit 1
}

Write-Host "`nAggregation completed successfully!" -ForegroundColor Green
