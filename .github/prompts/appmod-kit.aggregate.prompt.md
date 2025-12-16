---
description: Aggreate assessment report.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

The text the user typed after `/appmod-kit.aggregate` in the triggering message **is** the GitHub issue URI. Assume you always have it available in this conversation even if `$ARGUMENTS` appears literally below. Do not ask the user to repeat it unless they provided an invalid URI. If the user provided an empty command, then it means they do not want to track the assessment with a GitHub issue.


## Now do this:

1. **Extract GitHub issue URI**:
   - Extract the GitHub issue URI from the arguments
   - Do this ONLY if $ARGUMENTS is present
   - Validate the URI format (you can assume that syntax validity is enough)

2. **Detect the source of github issue**
   - If the Github Issue URI is present, use the 'github-mcp-server' tool to get the issue details.
   - Use below rules to detect if the issue is created by Azure Migrate: 
    - From the issue title and body, check if it contains content "estatetool=azuremigrate"
    - If no "estatetool=***" found, check if the title contains keyword "azure migrate".

3. Run `.appmod-kit/scripts/powershell/aggregate.ps1 -ReportFolder ./app-modernization -OutputFile .github/appmod/appcat/result/report.json`, make sure there is a report generated.

4. Run `.appmod-kit/scripts/powershell/assess.ps1 -Json -OutputPath .github/appmod/appcat/result -IssueSource other` from the repo root, set the issue source parameter value to azuremigrate if step2 detected the source is azure migrate.

5. When the script is done, verify that the file `.github/appmod/appcat/result/summary.md` is present.

6. **Update GitHub Issue**
   - If the GitHub issue URI is present in step1, use the 'github-mcp-server' tool or 'gh' cli to create a new comment with the raw content of `summary.md` file you verified in the previous step.
   - Do not append any additional text or formatting; the comment should contain only the raw content. 
   - If the summary.md file is too large to fit in a single GitHub comment, split the content into multiple comments, ensuring each comment is complete and coherent on its own.

7. **Generate At Scale Assessment Report**
   - Generate a comprehensive at-scale assessment report for this microservices application based on the aggregated AppCAT analysis in `.github\appmod\appcat\result\report.json`. The report should include:
   
   ✅ Application Identity & Metadata
      - Basic info (name, version, group ID)
      - Language, build tool, framework versions

   ✅ Technology Stack Summary
      - Runtime (Java, Spring Boot versions)
      - Project type (microservices pattern)
      - Logging & telemetry frameworks

   ✅ Dependencies
      - Package manager details
      - Direct dependencies grouped by category
      - Dependency management strategy

   ✅ Architecture
      - System architecture diagram (mermaid) showing all services
      - API endpoints map for each microservice
      - Data flow diagrams
      - Service dependency matrix

   ✅ Deployment Information
      - Deployment methods (Docker Compose, K8s, Azure)
      - Container configuration with detailed tables
      - Dockerfile analysis
      - Kubernetes manifests analysis
      - Azure IaC (Bicep/Terraform)
      - CI/CD pipeline configuration
      - Build artifacts & server requirements

      Update the summary report with the findings to `.github/appmod/appcat/result/at-scale-assessment.md` 

8. **Update GitHub Issue**
   - If the GitHub issue URI is present in step1, use the 'github-mcp-server' tool or 'gh' cli to create a new comment with the raw content of `at-scale-assessment.md` file you verified in the previous step.
   - Do not append any additional text or formatting; the comment should contain only the raw content. 
   - If the at-scale-assessment.md file is too large to fit in a single GitHub comment, split the content into multiple comments, ensuring each comment is complete and coherent on its own.
