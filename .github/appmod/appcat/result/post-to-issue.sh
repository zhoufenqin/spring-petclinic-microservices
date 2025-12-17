#!/bin/bash
# Script to post the summary.md content to GitHub issue #26
# Requires: gh CLI tool and GitHub authentication

ISSUE_NUMBER=26
REPO="zhoufenqin/spring-petclinic-microservices"
SUMMARY_FILE=".github/appmod/appcat/result/summary.md"

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "Error: gh CLI tool is not installed"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub. Run 'gh auth login' first"
    exit 1
fi

# Check if summary file exists
if [ ! -f "$SUMMARY_FILE" ]; then
    echo "Error: Summary file not found at $SUMMARY_FILE"
    exit 1
fi

# Post the comment
echo "Posting summary to issue #${ISSUE_NUMBER}..."
gh issue comment "$ISSUE_NUMBER" --repo "$REPO" --body-file "$SUMMARY_FILE"

if [ $? -eq 0 ]; then
    echo "Successfully posted summary to GitHub issue #${ISSUE_NUMBER}"
else
    echo "Failed to post summary to GitHub issue #${ISSUE_NUMBER}"
    exit 1
fi
