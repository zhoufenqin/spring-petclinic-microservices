# Upload Assessment Report Workflow

This workflow uploads the assessment report from this repository to a target repository via GitHub API.

## Overview

The workflow automates the process described in `.github/prompts/appmod-kit.upload.prompt.md` by:
1. Extracting repository information from a GitHub issue URL
2. Verifying the assessment report exists locally
3. Uploading the report to the target repository using the PowerShell script
4. Adding a comment to the target issue confirming the upload

## Prerequisites

1. **Assessment Report**: The report must exist at `.github/appmod/appcat/result/report.json` in this repository
2. **GitHub Token**: A GitHub Personal Access Token (PAT) with `repo` scope must be configured as a repository secret named `CROSS_REPO_TOKEN`
   - This token needs write access to the target repository
   - If not configured, the workflow will fall back to `GITHUB_TOKEN`, which may not have cross-repository permissions

## Usage

### Running the Workflow

1. Go to the Actions tab in this repository
2. Select "Upload Assessment Report" workflow
3. Click "Run workflow"
4. Fill in the inputs:
   - **target_issue_url**: The GitHub issue URL where the report should be tracked (e.g., `https://github.com/zhoufenqin/spring-petclinic-microservices-custom-service/issues/12`)
   - **target_branch** (optional): The branch to upload to (default: `main`)
5. Click "Run workflow"

### Example

For the issue at `https://github.com/zhoufenqin/spring-petclinic-microservices-custom-service/issues/12`:

1. Target Issue URL: `https://github.com/zhoufenqin/spring-petclinic-microservices-custom-service/issues/12`
2. Target Branch: `main` (default)

The workflow will:
- Extract: Owner=`zhoufenqin`, Repo=`spring-petclinic-microservices-custom-service`
- Upload `report.json` to: `zhoufenqin/spring-petclinic-microservices-custom-service` at path `.github/appmod/appcat/result/report.json`
- Add a comment to issue #12 with upload confirmation

## Manual Upload (Alternative)

If you prefer to upload manually using the PowerShell script directly:

```bash
# Set your GitHub token
export GH_TOKEN="your-github-token-here"

# Run the upload script
pwsh .appmod-kit/scripts/powershell/upload-to-github.ps1 \
  -FilePath ".github/appmod/appcat/result/report.json" \
  -RepoOwner "zhoufenqin" \
  -RepoName "spring-petclinic-microservices-custom-service" \
  -TargetPath ".github/appmod/appcat/result/report.json" \
  -Branch "main" \
  -CommitMessage "Upload assessment report"
```

## Troubleshooting

### Permission Denied (403 Forbidden)

If you get a 403 error, ensure:
1. The `CROSS_REPO_TOKEN` secret is properly configured
2. The token has `repo` scope permissions
3. The token has write access to the target repository

### File Not Found

If the workflow reports that the report file is not found:
1. Verify the assessment has been run: `ls -lh .github/appmod/appcat/result/report.json`
2. Check that you're running the workflow from the correct branch that contains the report

### Invalid Issue URL

The issue URL must be in the format: `https://github.com/owner/repo/issues/123`
- Make sure it's a complete URL, not just `owner/repo`
- Ensure the issue number is included

## Related Files

- Workflow: `.github/workflows/upload-assessment-report.yml`
- Upload Script: `.appmod-kit/scripts/powershell/upload-to-github.ps1`
- Prompt Instructions: `.github/prompts/appmod-kit.upload.prompt.md`
- Assessment Report: `.github/appmod/appcat/result/report.json`
