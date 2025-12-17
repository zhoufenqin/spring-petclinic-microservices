#!/bin/bash
# Script to post the assessment summary to a GitHub issue
# Usage: ./post-assessment-comment.sh <issue-number>
#
# Note: This script is configured for the zhoufenqin/spring-petclinic-microservices
# repository. To use with a different repository, set REPO_OWNER and REPO_NAME
# environment variables before running this script.

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <issue-number>"
    echo "Example: $0 30"
    exit 1
fi

ISSUE_NUMBER=$1
REPO_OWNER="${REPO_OWNER:-zhoufenqin}"
REPO_NAME="${REPO_NAME:-spring-petclinic-microservices}"
SUMMARY_FILE=".github/appmod/appcat/result/summary.md"

# Check if summary file exists
if [ ! -f "$SUMMARY_FILE" ]; then
    echo "Error: Summary file not found at $SUMMARY_FILE"
    exit 1
fi

# Check if GH_TOKEN or GITHUB_TOKEN is set
if [ -z "$GH_TOKEN" ] && [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GH_TOKEN or GITHUB_TOKEN environment variable must be set"
    echo "You can obtain a token from https://github.com/settings/tokens"
    exit 1
fi

TOKEN="${GH_TOKEN:-$GITHUB_TOKEN}"

echo "Posting assessment summary to issue #${ISSUE_NUMBER}..."

# Read the summary content
SUMMARY_CONTENT=$(cat "$SUMMARY_FILE")

# Escape JSON special characters using jq
ESCAPED_CONTENT=$(echo "$SUMMARY_CONTENT" | jq -Rs .)

# Post comment using GitHub API
RESPONSE=$(curl -s -X POST \
  -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues/${ISSUE_NUMBER}/comments" \
  -d "{\"body\": ${ESCAPED_CONTENT}}")

# Check if comment was posted successfully
if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
    COMMENT_URL=$(echo "$RESPONSE" | jq -r '.html_url')
    echo "✓ Comment posted successfully!"
    echo "Comment URL: $COMMENT_URL"
else
    echo "✗ Failed to post comment"
    echo "Response: $RESPONSE"
    exit 1
fi
