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
   - Generate an at-scale assessment report for architects and technical decision makers based on the aggregated AppCAT analysis in `.github\appmod\appcat\result\report.json` and `.github\appmod\appcat\result\summary.md`.
   - **Target Audience**: Architects / Technical Decision Makers
   - **Purpose**: Provide insights for migration decision making (reveal what portfolio assessment cannot show)
   - **Scope**: Focus on code-level readiness signals per application
   
   The report MUST follow this structure:

   ---

   ## Application Profile
   
   Start with a brief introduction: "This report contains X repositories with their technology stacks."
   
   For EACH repository, provide:
   
   ### Repository: [repository-name]
   
   List all information in a flat bullet-point format (no subsections):
   - Primary language and version
   - Build tool (Maven, Gradle, npm, etc.)
   - Primary frameworks and versions (e.g., Spring Boot 3.x, .NET 8, etc.)
   - Runtime assumptions (e.g., container-based, VM-based, serverless)
   - **Service type:** Frontend / Backend / Full-stack / CLI / Library / etc.
     - If Backend: REST API / GraphQL / gRPC / Message consumer / etc.
     - If Frontend: Web UI / Mobile / Desktop / etc.
   - **Module structure:** Single module / Multi-module / Monorepo
   - **Key dependencies:** Critical external dependencies (databases, message queues, service discovery, config servers, etc.)

   ### Repository: [repository-name-2]
   [Repeat the same structure]

   ---

   ## Issue Insights Summary
   
   ### Repository comparison
   
   Create a comparison table for ALL repositories:
   
   | Repository | Cloud Readiness | Upgrade Readiness | Security Readiness | Top Blockers |
   |-----------|-----------------|-------------------|--------------------|--------------|
   | repo-name | XX% | YY% | ZZ% | Brief summary (2-3 words) |
   
   **Calculate readiness scores** using issue severity:
   - Cloud readiness = Impact of cloud-related mandatory issues on cloud deployment
   - Upgrade readiness = Impact of framework/language upgrade mandatory issues
   - Security readiness = Impact of security mandatory issues on compliance
   - Use this formula: `(1 - mandatory_issues_in_category / total_issues_in_category) × 100`
   - If no issues in a category, score is 100%
   
   **Top Blockers** column: List 2-3 most critical issues for each repository (brief titles only, NOT full issue descriptions)
   
   **After the table, provide readiness calculation notes:**
   - Explain what each readiness metric measures
   - Brief description of the calculation methodology
   - Context about what these scores indicate
   
   ### Detailed statistics
   
   For EACH repository, provide detailed statistics:
   
   #### Repository: [repository-name]
   
   **Readiness by domain**
   
   | Domain | Score | Status |
   |--------|-------|--------|
   | Cloud readiness | XX% | 🔴/🟡/🟢 (based on score) |
   | Upgrade readiness | YY% | 🔴/🟡/🟢 |
   | Security readiness | ZZ% | 🔴/🟡/🟢 |
   
   Use color coding: 🔴 Low (<50%), 🟡 Medium (50-75%), 🟢 High (>75%)
   
   **Severity distribution**
   
   | Severity | Count | Percentage | What It Means |
   |----------|-------|------------|---------------|
   | Mandatory | X | XX% | Must fix for migration |
   | Potential | Y | YY% | Review required |
   | Optional | Z | ZZ% | Post-migration improvement |

   **After the first repository's severity distribution table, provide severity levels explanation:**
   - Explain what each severity level means
   - Mandatory: Must be resolved for successful migration
   - Potential: May be blocking in some situations, requires review
   - Optional: Real issues that can improve the app but not blocking

   #### Repository: [repository-name-2]
   [Repeat the same structure for each repository]
   
   ---

   **FORMATTING RULES**:
   - Focus on **per-repository details**, not system-wide aggregation
   - Use **percentages and proportions** (not just absolute numbers)
   - Use **readiness scores** (0-100%) for quick assessment
   - Use **tables** for structured data presentation
   - **Avoid listing every individual issue** (summarize patterns instead)
   - Keep it **concise** (focus on key metrics per repository)
   - Use **visual indicators**: 🔴 Low (<50%), 🟡 Medium (50-75%), 🟢 High (>75%)
   - **NO detailed code snippets, NO full Dockerfiles, NO full deployment manifests**
   - **DO NOT include** header metadata at the top of the report
   - Use normal sentence case for section titles, not uppercase
   
   Update the summary report with the findings to `.github/appmod/appcat/result/at-scale-assessment.md` 

8. **Update GitHub Issue**
   - If the GitHub issue URI is present in step1, use the 'github-mcp-server' tool or 'gh' cli to create a new comment with the raw content of `at-scale-assessment.md` file you verified in the previous step.
   - Do not append any additional text or formatting; the comment should contain only the raw content. 
   - If the at-scale-assessment.md file is too large to fit in a single GitHub comment, split the content into multiple comments, ensuring each comment is complete and coherent on its own.
