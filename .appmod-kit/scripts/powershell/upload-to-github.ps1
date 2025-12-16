#!/usr/bin/env pwsh
# Script to upload a file to a GitHub repository
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    
    [Parameter(Mandatory=$true)]
    [string]$RepoOwner,
    
    [Parameter(Mandatory=$true)]
    [string]$RepoName,
    
    [Parameter(Mandatory=$true)]
    [string]$TargetPath,
    
    [Parameter(Mandatory=$false)]
    [string]$Branch = 'main',
    
    [Parameter(Mandatory=$false)]
    [string]$CommitMessage = 'Upload file via script',
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubToken,
    
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

function Show-Help {
    Write-Host @"
Usage: upload-to-github.ps1 -FilePath <path> -RepoOwner <owner> -RepoName <name> -TargetPath <path> [-Branch <branch>] [-CommitMessage <message>] [-GitHubToken <token>]

Upload a file to a GitHub repository using the GitHub API.

Parameters:
  -FilePath        Path to the local file to upload (required)
  -RepoOwner       GitHub repository owner/organization (required)
  -RepoName        GitHub repository name (required)
  -TargetPath      Target path in the repository (e.g., '.github/appmod/appcat/result/report.json') (required)
  -Branch          Target branch (default: 'main')
  -CommitMessage   Commit message (default: 'Upload file via script')
  -GitHubToken     GitHub personal access token (if not provided, will use GH_TOKEN environment variable)
  -Help            Show this help message

Examples:
  # Upload a file to main branch
  .\upload-to-github.ps1 -FilePath ".github\appmod\appcat\result\report.json" `
                         -RepoOwner "zhoufenqin" `
                         -RepoName "spring-petclinic-microservices-custom-service" `
                         -TargetPath ".github/appmod/appcat/result/report.json"

  # Upload with custom branch and commit message
  .\upload-to-github.ps1 -FilePath "local\path\to\file.json" `
                         -RepoOwner "myorg" `
                         -RepoName "myrepo" `
                         -TargetPath "remote/path/file.json" `
                         -Branch "develop" `
                         -CommitMessage "Update report"

  # Upload with explicit token
  .\upload-to-github.ps1 -FilePath "report.json" `
                         -RepoOwner "myorg" `
                         -RepoName "myrepo" `
                         -TargetPath "reports/report.json" `
                         -GitHubToken "ghp_xxxxxxxxxxxxx"

Requirements:
  - GitHub personal access token with 'repo' scope
  - Token should be set in GH_TOKEN environment variable or passed via -GitHubToken parameter
"@
}

function Get-GitHubToken {
    param([string]$Token)
    
    if ($Token) {
        return $Token
    }
    
    if ($env:GH_TOKEN) {
        return $env:GH_TOKEN
    }
    
    if ($env:GITHUB_TOKEN) {
        return $env:GITHUB_TOKEN
    }
    
    throw "GitHub token not found. Please set GH_TOKEN environment variable or provide -GitHubToken parameter."
}

function Convert-FileToBase64 {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        throw "File not found: $Path"
    }
    
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    return [System.Convert]::ToBase64String($bytes)
}

function Get-FileSha {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$Path,
        [string]$Branch,
        [string]$Token
    )
    
    # Build the API URL - don't encode, GitHub API handles paths as-is
    $apiUrl = "https://api.github.com/repos/$Owner/$Repo/contents/$Path"
    
    $headers = @{
        'Authorization' = "Bearer $Token"
        'Accept' = 'application/vnd.github.v3+json'
        'User-Agent' = 'PowerShell-Upload-Script'
    }
    
    try {
        $uri = [System.Uri]::new($apiUrl)
        $response = Invoke-RestMethod -Uri "$($uri.ToString())?ref=$Branch" -Headers $headers -Method Get
        return $response.sha
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            return $null  # File doesn't exist yet
        }
        throw
    }
}

function Upload-FileToGitHub {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$Path,
        [string]$Branch,
        [string]$Content,
        [string]$Message,
        [string]$Token,
        [string]$Sha
    )
    
    # Build the API URL - don't encode, GitHub API handles paths as-is
    $apiUrl = "https://api.github.com/repos/$Owner/$Repo/contents/$Path"
    
    $headers = @{
        'Authorization' = "Bearer $Token"
        'Accept' = 'application/vnd.github.v3+json'
        'Content-Type' = 'application/json'
        'User-Agent' = 'PowerShell-Upload-Script'
    }
    
    $body = @{
        message = $Message
        content = $Content
        branch = $Branch
    }
    
    if ($Sha) {
        $body.sha = $Sha
    }
    
    $jsonBody = $body | ConvertTo-Json
    
    $uri = [System.Uri]::new($apiUrl)
    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Put -Body $jsonBody
    return $response
}

# Main script execution
if ($Help) {
    Show-Help
    exit 0
}

try {
    Write-Host "Starting file upload to GitHub..." -ForegroundColor Cyan
    
    # Validate file exists
    if (-not (Test-Path $FilePath)) {
        throw "File not found: $FilePath"
    }
    
    # Get absolute path
    $absolutePath = Resolve-Path $FilePath
    Write-Host "Local file: $absolutePath" -ForegroundColor Gray
    
    # Get GitHub token
    $token = Get-GitHubToken -Token $GitHubToken
    Write-Host "GitHub token: Found" -ForegroundColor Gray
    
    # Normalize target path (use forward slashes for GitHub, remove leading ./)
    $normalizedTargetPath = $TargetPath -replace '\\', '/'
    $normalizedTargetPath = $normalizedTargetPath -replace '^\./', ''
    $normalizedTargetPath = $normalizedTargetPath.TrimStart('/')
    Write-Host "Target: $RepoOwner/$RepoName/$normalizedTargetPath (branch: $Branch)" -ForegroundColor Gray
    
    # Convert file to base64
    Write-Host "Encoding file content..." -ForegroundColor Yellow
    $base64Content = Convert-FileToBase64 -Path $absolutePath
    
    # Check if file already exists (to get SHA for update)
    Write-Host "Checking if file exists in repository..." -ForegroundColor Yellow
    $existingSha = Get-FileSha -Owner $RepoOwner -Repo $RepoName -Path $normalizedTargetPath -Branch $Branch -Token $token
    
    if ($existingSha) {
        Write-Host "File exists. Updating..." -ForegroundColor Yellow
    }
    else {
        Write-Host "File doesn't exist. Creating new file..." -ForegroundColor Yellow
    }
    
    # Upload file
    Write-Host "Uploading file..." -ForegroundColor Yellow
    $result = Upload-FileToGitHub `
        -Owner $RepoOwner `
        -Repo $RepoName `
        -Path $normalizedTargetPath `
        -Branch $Branch `
        -Content $base64Content `
        -Message $CommitMessage `
        -Token $token `
        -Sha $existingSha
    
    Write-Host "`nSuccess! File uploaded to GitHub." -ForegroundColor Green
    Write-Host "Commit SHA: $($result.commit.sha)" -ForegroundColor Gray
    Write-Host "File URL: $($result.content.html_url)" -ForegroundColor Cyan
    
    exit 0
}
catch {
    Write-Host "`nError: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "HTTP Status Code: $statusCode" -ForegroundColor Red
    }
    Write-Host "`nUse -Help to see usage information" -ForegroundColor Yellow
    exit 1
}
