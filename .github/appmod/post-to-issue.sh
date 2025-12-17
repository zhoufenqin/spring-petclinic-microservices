#!/bin/bash
# Script to post assessment summary to GitHub issue #32
# This script requires GH_TOKEN to be set in the environment

set -e

ISSUE_NUMBER=32
SUMMARY_FILE=".github/appmod/appcat/result/summary.md"
REPO="zhoufenqin/spring-petclinic-microservices"

# Check if summary file exists
if [ ! -f "$SUMMARY_FILE" ]; then
    echo "Error: Summary file not found at $SUMMARY_FILE"
    exit 1
fi

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "Error: gh CLI is not installed"
    exit 1
fi

# Check if GH_TOKEN is set
if [ -z "$GH_TOKEN" ]; then
    echo "Error: GH_TOKEN environment variable is not set"
    echo "Please set it with: export GH_TOKEN=your_github_token"
    exit 1
fi

echo "Posting assessment summary to issue #$ISSUE_NUMBER..."

# Post the comment
gh issue comment "$ISSUE_NUMBER" \
    --repo "$REPO" \
    --body-file "$SUMMARY_FILE"

echo "Successfully posted assessment summary to issue #$ISSUE_NUMBER"
echo "View at: https://github.com/$REPO/issues/$ISSUE_NUMBER"
