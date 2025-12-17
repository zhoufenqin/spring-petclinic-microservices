# Configuring CROSS_REPO_TOKEN for Assessment Report Upload

## Why is this needed?

The "Upload Assessment Report" workflow needs to upload files to a different repository. The default `GITHUB_TOKEN` provided by GitHub Actions only has permissions for the current repository. To upload to another repository, you need a Personal Access Token (PAT) with broader permissions.

## Setup Instructions

### 1. Create a GitHub Personal Access Token (PAT)

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Direct link: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Give it a descriptive name: "Assessment Report Upload Token"
4. Set expiration as needed (recommended: 90 days or custom)
5. Select the following scopes:
   - ✅ **repo** (Full control of private repositories)
     - This includes: repo:status, repo_deployment, public_repo, repo:invite, security_events
6. Click "Generate token"
7. **IMPORTANT**: Copy the token immediately - you won't be able to see it again!

### 2. Add the Token as a Repository Secret

1. Go to this repository's Settings → Secrets and variables → Actions
   - Direct link: `https://github.com/zhoufenqin/spring-petclinic-microservices/settings/secrets/actions`
2. Click "New repository secret"
3. Name: `CROSS_REPO_TOKEN`
4. Value: Paste the PAT you copied in step 1
5. Click "Add secret"

### 3. Verify the Setup

1. Go to Actions tab
2. Select "Upload Assessment Report" workflow
3. Click "Run workflow"
4. Enter the target issue URL (e.g., `https://github.com/zhoufenqin/spring-petclinic-microservices-custom-service/issues/12`)
5. Click "Run workflow"
6. Monitor the workflow execution - it should succeed if the token is configured correctly

## Token Permissions Required

The token needs access to:
- **Source repository** (this repo): Read access to get the assessment report
- **Target repository**: Write access to upload the report file

Make sure the GitHub account that created the token has write access to the target repository.

## Security Best Practices

1. **Use fine-grained tokens when possible**: While this guide uses classic tokens, consider using fine-grained tokens with repository-specific permissions for better security
2. **Rotate tokens regularly**: Set expiration dates and rotate tokens periodically
3. **Minimum permissions**: Only grant the permissions needed (repo scope for this workflow)
4. **Monitor usage**: Review the Actions logs to ensure the token is being used as expected
5. **Revoke if compromised**: If you suspect the token has been compromised, immediately revoke it and create a new one

## Troubleshooting

### "GitHub token not found" error
- Verify the secret is named exactly `CROSS_REPO_TOKEN` (case-sensitive)
- Check that the secret is added to the repository secrets (not environment secrets)

### "403 Forbidden" error
- Verify the token has `repo` scope
- Ensure the GitHub account that created the token has write access to the target repository
- Check that the token hasn't expired

### "Token doesn't have permission" error
- The token needs write access to the target repository
- Make sure you're not using a fine-grained token restricted to specific repositories (unless the target repo is included)

## Alternative: Organization-Level Secret

If you have multiple repositories that need to upload reports, consider creating an organization-level secret:
1. Go to Organization Settings → Secrets and variables → Actions
2. Create a secret named `CROSS_REPO_TOKEN`
3. Select which repositories can access it
4. This secret will be available to all selected repositories without individual configuration
