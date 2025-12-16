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
   - Generate a comprehensive at-scale assessment report for this microservices application based on the aggregated AppCAT analysis in `.github\appmod\appcat\result\report.json` and `.github\appmod\appcat\result\summary.md`. The report should include:
   
   ✅ **Executive Summary**
      - Total applications analyzed with names
      - Overall migration readiness score (High/Medium/Low)
      - Total critical blockers (mandatory issues count)
      - Total estimated effort (story points)
      - Recommended migration approach (wave-based, service-by-service, all-at-once)
      - Key risks and mitigation strategies
   
   ✅ **Application Portfolio Overview** (CRITICAL - Must Compare All Apps)
      - Create a comparison table with ALL applications showing: Application name, Language/version, Framework versions, Mandatory/Potential/Optional issue counts, Story points, Complexity score, Dependencies
      - Complexity scoring criteria: LOW (<10 mandatory), MEDIUM (10-500 mandatory), HIGH (>500 mandatory)
   
   ✅ **Application Profile Details** (Detailed Profile for Each App)
      For EACH application, analyze and include:
      
      - **Basic Information**: App name, version, group/artifact ID, project type, packaging, repository path
      - **Language & Build**: Primary languages, language versions, build tool, package manager
      - **Runtime Environment**: Runtime platform/version, startup config, embedded servers, instrumentation
      - **Framework & Tech Stack**: Web framework, application framework, data access, API tech, auth, logging, monitoring, testing frameworks, template engines (create a table with framework categories)
      - **Dependencies**: Direct/transitive dependency counts, key SDKs (Azure/AWS/database/messaging/HTTP clients), dependency management strategy, environment dependencies (external services, config sources, secret management)
      - **Deployment Configuration**: Current deployment method, containerization status (Dockerfile present/missing, base image, registry), orchestration (K8s/Docker Compose/Helm), port configuration, health check endpoints
      - **Architecture Role**: Service type, upstream dependencies, downstream consumers, data persistence, critical path indicator
      - **API Surface**: REST endpoint count, GraphQL/gRPC services, message queue topics
   
   ✅ **Common Issues Analysis** (CRITICAL - Show Patterns Across Apps)
      - **Shared Blockers** (issues in ALL applications):
        * List each common issue with:
          - Rule ID and title
          - Total occurrences across all apps (e.g., "1,551 locations across 3 services")
          - Severity and impact
          - Single unified solution recommendation
          - Effort to fix once for all apps
        * Examples: unsecure-network-protocol, missing-dockerfiles, container-registry-migration
      
      - **Partial Blockers** (issues in SOME applications):
        * Which apps have the issue
        * Why only certain apps affected
        * App-specific vs. shared solution needed
      
      - **Application-Specific Issues**:
        * Unique issues per application
        * Root cause analysis
        * Individual remediation plans
      
      - Create a visual heat map:
        ```
        | Issue Category              | App 1 | App 2 | App 3 | Total | Priority |
        |-----------------------------|-------|-------|-------|-------|----------|
        | Unsecured Protocols         | 517   | 517   | 517   | 1,551 | 🔴 CRITICAL |
        | Container Registry          | 4     | 4     | 4     | 12    | 🔴 CRITICAL |
        | AWS Credentials             | 2     | 0     | 1     | 3     | 🟡 HIGH     |
        | Missing Dockerfiles         | 1     | 1     | 1     | 3     | 🟡 HIGH     |
        | Hardcoded URLs              | 3,005 | 3,005 | 3,005 | 9,015 | 🟢 LOW      |
        ```
   
   ✅ **Migration Complexity Matrix**
      - Complexity score calculation for each app:
        * Mandatory issues weight: 5x
        * Potential issues weight: 2x
        * Optional issues weight: 0.5x
        * Dependencies weight: +50 per dependency
      - Sort applications by complexity (easiest to hardest)
      - Highlight quick wins vs. complex migrations
   
   ✅ **Migration Waves Recommendation** (CRITICAL - Provide Roadmap)
      - **Wave 1 (Quick Wins - Week 1-2)**:
        * Services: [list services with LOW complexity]
        * Rationale: Few blockers, independent, low risk
        * Estimated timeline: X days
        * Prerequisites: Common infra (config server, discovery)
        * Expected outcomes: Validate migration process
      
      - **Wave 2 (Medium Risk - Week 3-4)**:
        * Services: [list services with MEDIUM complexity]
        * Rationale: More blockers but manageable, some dependencies
        * Estimated timeline: X days
        * Prerequisites: Wave 1 success, shared solutions implemented
      
      - **Wave 3 (High Risk - Week 5-8)**:
        * Services: [list services with HIGH complexity]
        * Rationale: Complex dependencies, many blockers
        * Estimated timeline: X days
        * Prerequisites: Lessons learned from Wave 1 & 2
      
      - **Parallel vs. Sequential**:
        * Which services can be migrated in parallel
        * Which must be sequential due to dependencies
        * Resource allocation recommendations
   
   ✅ **Technology Stack Summary**
      - Consolidated view across all applications:
        * Java versions (consistency check)
        * Spring Boot versions (consistency check)
        * Spring Cloud versions (consistency check)
        * Database drivers and versions
        * Deprecated libraries
      - Version inconsistencies and recommendations
      - Upgrade opportunities
   
   ✅ **Architecture Overview** (Brief - Focus on Migration Impact)
      - High-level system architecture diagram (mermaid)
      - Service dependency graph with critical paths
      - Infrastructure services (config, discovery, gateway)
      - Data layer dependencies
      - **Do NOT include**: Detailed Dockerfile content, full K8s manifests, detailed deployment configs
   
   ✅ **Risk Assessment** (CRITICAL - Prioritize Actions)
      - **🔴 Critical Risks** (Must fix before migration):
        * Issue category
        * Affected applications
        * Impact if not resolved
        * Recommended solution
        * Effort estimation
      
      - **🟡 Medium Risks** (Fix during migration):
        * Similar structure as above
      
      - **🟢 Low Risks** (Post-migration improvements):
        * Can be deferred
        * Nice-to-have optimizations
      
      - **Shared Infrastructure Concerns**:
        * Database migration strategy
        * Messaging service decisions
        * Caching strategy
        * Service discovery approach
   
   ✅ **Next Steps & Action Plan** (CRITICAL - Make It Actionable)
      - **Immediate Actions (This Week)**:
        1. Fix common security issues (unsecured protocols)
        2. Create missing Dockerfiles (template provided)
        3. Migrate container registry references
        4. Remove AWS credential configs
      
      - **Short-Term Actions (Weeks 2-4)**:
        1. Implement Azure Managed Identity
        2. Set up Azure Key Vault for secrets
        3. Containerize all services
        4. Set up Azure Container Registry
        5. Deploy Wave 1 services
      
      - **Long-Term Actions (Months 2-3)**:
        1. Migrate remaining services (Wave 2 & 3)
        2. Implement monitoring and observability
        3. Performance optimization
        4. Address optional improvements
      
      - **Key Decision Points**:
        * Choose Azure target service (ASA vs. AKS vs. ACA)
        * Database strategy (managed vs. self-hosted)
        * Service discovery approach (keep Eureka vs. Azure-native)
        * Configuration management (keep Spring Config vs. Azure App Config)
      
      - **Success Criteria**:
        * All mandatory issues resolved
        * All services successfully deployed to Azure
        * Performance SLAs met
        * Zero critical security vulnerabilities
   
   **IMPORTANT FORMATTING RULES**:
   - Use emoji indicators: 🔴 Critical/High, 🟡 Medium, 🟢 Low, ✅ Complete, ❌ Blocker, ⚠️ Warning
   - Use tables for ALL cross-application comparisons
   - Prioritize insights over raw data dumps
   - Focus on actionable recommendations, not just observations
   - Highlight common patterns and shared solutions
   - Keep deployment details brief (reference existing docs, don't duplicate)
   - Use collapsible sections for detailed data
   - Maximum 2 mermaid diagrams (architecture + dependency graph)
   - NO full Dockerfiles, NO full K8s manifests, NO full Bicep files in the report
   
   Update the summary report with the findings to `.github/appmod/appcat/result/at-scale-assessment.md` 

8. **Update GitHub Issue**
   - If the GitHub issue URI is present in step1, use the 'github-mcp-server' tool or 'gh' cli to create a new comment with the raw content of `at-scale-assessment.md` file you verified in the previous step.
   - Do not append any additional text or formatting; the comment should contain only the raw content. 
   - If the at-scale-assessment.md file is too large to fit in a single GitHub comment, split the content into multiple comments, ensuring each comment is complete and coherent on its own.
