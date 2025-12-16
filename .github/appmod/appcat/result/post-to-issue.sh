#!/bin/bash
# Script to post the assessment summary to GitHub issue #20
# This script should be run in an environment with proper GitHub API access

REPO_OWNER="zhoufenqin"
REPO_NAME="spring-petclinic-microservices"
ISSUE_NUMBER="20"
SUMMARY_FILE=".github/appmod/appcat/result/summary.md"

# Check if summary file exists
if [ ! -f "$SUMMARY_FILE" ]; then
    echo "Error: Summary file not found at $SUMMARY_FILE"
    exit 1
fi

# Check if gh CLI is available
if command -v gh &> /dev/null; then
    echo "Using gh CLI to post comment..."
    gh issue comment "$ISSUE_NUMBER" --body-file "$SUMMARY_FILE" \
        --repo "$REPO_OWNER/$REPO_NAME"
    exit $?
fi

# Fallback to curl if gh is not available
if [ -z "$GITHUB_TOKEN" ] && [ -z "$GH_TOKEN" ]; then
    echo "Error: Neither GITHUB_TOKEN nor GH_TOKEN is set"
    exit 1
fi

TOKEN="${GITHUB_TOKEN:-$GH_TOKEN}"

echo "Using curl to post comment..."
jq -Rs '{body: .}' < "$SUMMARY_FILE" | \
    curl -X POST \
        -H "Authorization: token $TOKEN" \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/issues/$ISSUE_NUMBER/comments" \
        --data @-

echo ""
echo "Comment posting complete"
