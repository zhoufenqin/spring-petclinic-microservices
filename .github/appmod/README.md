# App Modernization Assessment Aggregation

This directory contains the aggregated assessment reports for the Spring PetClinic Microservices application.

## Overview

The assessment aggregation process combines multiple AppCAT (Application Containerization Assessment Tool) reports from individual services into a single comprehensive report with a human-readable summary.

## Generated Files

- **`appcat/result/report.json`**: Aggregated JSON report combining all service-specific assessment reports
- **`appcat/result/summary.md`**: Human-readable markdown summary of the assessment findings

## Process

The aggregation is performed using the following steps:

### 1. Aggregate Reports

```bash
pwsh .appmod-kit/scripts/powershell/aggregate.ps1 \
  -ReportFolder ./app-modernization \
  -OutputFile .github/appmod/appcat/result/report.json
```

This script:
- Merges multiple AppCAT JSON report files from the `app-modernization` folder
- Combines projects from all reports
- Deduplicates rules across reports
- Recalculates summary statistics (total issues, incidents, effort, severity distribution)

### 2. Generate Summary

```bash
pwsh .appmod-kit/scripts/powershell/assess.ps1 \
  -Json \
  -OutputPath .github/appmod/appcat/result \
  -IssueSource other
```

This script:
- Reads the aggregated report.json
- Generates a human-readable summary in markdown format
- Groups findings by application and severity
- Includes application profiles (JDK version, frameworks, build tools)
- Highlights key findings for each severity level

### 3. Post to GitHub Issue

There are three ways to post the summary to a GitHub issue:

#### Option A: Use GitHub Actions Workflow (Recommended)

1. Go to the repository's Actions tab
2. Select "Post Assessment Summary to Issue" workflow
3. Click "Run workflow"
4. Enter the issue number (e.g., 30)
5. Click "Run workflow" button

#### Option B: Use the Helper Script

```bash
# Set your GitHub token
export GH_TOKEN=your_github_token_here

# Run the script with the issue number
./.github/appmod/post-assessment-comment.sh 30
```

#### Option C: Manual Copy-Paste

Manually copy the content of `appcat/result/summary.md` and paste it as a comment on the GitHub issue.

## Assessment Summary

The current assessment covers **3 applications**:
- **customers-service**: 7 mandatory, 18 potential, 4 optional issues
- **vets-service**: 5 mandatory, 17 potential, 5 optional issues
- **visits-service**: 6 mandatory, 18 potential, 4 optional issues

**Target Azure Services**: Azure Kubernetes Service, Azure Container Apps, Azure App Service

See [summary.md](appcat/result/summary.md) for detailed findings.

## Next Steps

For comprehensive migration guidance and best practices, visit:
- [GitHub Copilot App Modernization](https://aka.ms/ghcp-appmod)
