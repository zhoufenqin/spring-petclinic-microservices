---
description: upload assessment report.
---


## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

The text the user typed after `/appmod-kit.upload` in the triggering message **is** the GitHub issue URI. Assume you always have it available in this conversation even if `$ARGUMENTS` appears literally below. Do not ask the user to repeat it unless they provided an invalid URI. If the user provided an empty command, then it means they do not want to track the assessment with a GitHub issue.


## Now do this:
1. Extract the GitHub repo from the GitHub issue URI provided in the user input.

2. Run the PowerShell script `.appmod-kit/scripts/powershell/upload-to-github.ps1` to upload the assessment report file located at `.github\appmod\appcat\result\report.json` to the GitHub repository extracted in step 1. Use the following parameters:
   - `-FilePath`: Path to the local assessment report file `.github\appmod\appcat\result\report.json`.
   - `-RepoOwner`: The owner of the GitHub repository (extracted from the issue URI).
   - `-RepoName`: The name of the GitHub repository (extracted from the issue URI).
   - `-TargetPath`: The target path in the repository where the report should be uploaded, which is `.github/appmod/appcat/result/report.json`.
   - `-Branch`: The branch to which the file should be uploaded, typically `main`.
   - `-CommitMessage`: A commit message for the upload, e.g., "Upload assessment report".
   - `-GitHubToken`: Use an appropriate GitHub token with permissions to upload files to the repository.

