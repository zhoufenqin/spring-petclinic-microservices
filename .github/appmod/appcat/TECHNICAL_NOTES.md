# AppCAT Assessment - Technical Notes and Troubleshooting

## Issue: JDTLS Timeout During Assessment

### Problem Description

The AppCAT assessment consistently failed at rule 65/266 with the following error:

```
Error: JDTLS service has timed out 5 consecutive times. 
This indicates the language server may be unresponsive. 
Please retry the analysis
```

### Timeline of Attempts

1. **First Attempt** (via appmod-run-assessment tool)
   - Failed at rule 65/266
   - Time: ~10 minutes before timeout
   
2. **Second Attempt** (via appmod-run-assessment tool)
   - Same failure point
   - Confirmed consistent timeout behavior

3. **Third Attempt** (manual execution with --no-cleanup)
   - Same failure at rule 65/266
   - Duration: ~10 minutes
   - Logs preserved in analysis.log

### Root Cause Analysis

**JDTLS (Java Development Tools Language Server)** is used by AppCAT to perform deep code analysis on Java projects. The timeout occurs when:

1. **Large Project Size**: This is a multi-module Maven project with 7 microservices
2. **Complex Dependencies**: Spring Cloud ecosystem has many transitive dependencies
3. **Resource Constraints**: Limited memory or CPU in the execution environment
4. **Language Server Responsiveness**: JDTLS may become unresponsive during intensive analysis

### Specific Rule Where Failure Occurred

The assessment consistently failed while processing:
- **Rule ID**: `azure-aws-config-sqs-04001`
- **Rule Number**: 65 of 266 (24.4% complete)
- **Category**: AWS to Azure migration rules (SQS related)

### Assessment Configuration Used

```yaml
targets:
  - azure-aks
  - azure-appservice
  - azure-container-apps

mode: issue-only

input: /home/runner/work/spring-petclinic-microservices/spring-petclinic-microservices
output: .github/appmod/appcat/result
```

### Rules Successfully Processed

The following rule categories were successfully analyzed:

1. **AWS to Azure Migration Rules** (Partial: 1-14)
   - SQS configuration checks
   - Region configuration
   - Credentials handling
   - S3 migration considerations

2. **File System Rules** (5-6)
   - File system access patterns

3. **Database Rules** (7, 36-43)
   - MongoDB configuration
   - MySQL compatibility
   - PostgreSQL compatibility
   - SQL Server compatibility
   - Cassandra considerations
   - MariaDB compatibility
   - Oracle compatibility
   - Database reliability patterns

4. **Java Version Rules** (8, 12)
   - Java version compatibility checks

5. **Cache Rules** (9)
   - Redis integration

6. **Keystore Rules** (10)
   - Certificate management

7. **Message Queue Rules** (15-22)
   - RabbitMQ configuration
   - Artemis configuration
   - ActiveMQ integration
   - AMQP protocols
   - Kafka configuration

8. **Password Management** (20)
   - Password handling patterns

9. **TAS Binding** (21)
   - Tanzu Application Service bindings

10. **Spring Boot to Azure Rules** (24-35)
    - Config Server integration
    - Eureka service discovery
    - Port configuration
    - Restricted configurations
    - Scheduled jobs
    - Spring Boot version compatibility
    - Spring Cloud version compatibility
    - Key Vault integration
    - OpenFeign integration

11. **Authentication Rules** (49-53)
    - Authentication patterns

12. **APM Rules** (44-46)
    - Application Performance Monitoring

13. **OpenLiberty Rules** (54-64)
    - Database integration
    - File system access

### Partial Results

Even though the assessment did not complete, valuable analysis was performed on:
- Spring Cloud Config Server usage
- Eureka service discovery patterns
- Database connection patterns
- Message queue configurations
- Authentication mechanisms

## Workarounds and Alternatives

### Option 1: Module-by-Module Assessment

Run AppCAT on each microservice individually:

```bash
# Example for customers-service
appcat analyze \
  --input spring-petclinic-customers-service \
  --output .github/appmod/appcat/result-customers \
  --mode issue-only \
  --target azure-aks \
  --target azure-appservice \
  --target azure-container-apps
```

Repeat for each module:
- spring-petclinic-admin-server
- spring-petclinic-api-gateway
- spring-petclinic-config-server
- spring-petclinic-customers-service
- spring-petclinic-discovery-server
- spring-petclinic-vets-service
- spring-petclinic-visits-service

**Advantages**:
- Smaller codebase per analysis
- Less likely to timeout
- Can parallelize assessments

**Disadvantages**:
- More manual work to combine results
- May miss cross-module dependencies

### Option 2: Increase Resource Limits

If running in a containerized environment:

```bash
# Set JDTLS memory limits
export JDTLS_JVM_ARGS="-Xmx4g -Xms1g"

# Run with increased timeout (if supported)
appcat analyze \
  --input . \
  --output result \
  --mode issue-only \
  --target azure-aks \
  --log-level 5
```

### Option 3: Use Source-Only Mode

Instead of issue-only mode, try source-only which may be less resource-intensive:

```bash
appcat analyze \
  --input . \
  --output result \
  --mode source-only \
  --target azure-aks
```

### Option 4: Analyze Compiled JARs

Build the project first and analyze the JAR files instead of source code:

```bash
# Build the project
./mvnw clean package -DskipTests

# Analyze JARs
appcat analyze \
  --input spring-petclinic-customers-service/target/*.jar \
  --output result-customers \
  --mode issue-only \
  --target azure-aks
```

### Option 5: Use Alternative Assessment Tools

Consider complementary tools:

1. **Azure Migrate Appliance**
   - Provides application discovery
   - Dependency mapping
   - Performance-based sizing

2. **Microsoft Assessment and Planning (MAP) Toolkit**
   - Inventory and readiness assessment
   - Works with various application types

3. **Manual Code Review Checklist**
   - Use the partially completed AppCAT results as a guide
   - Focus on areas identified in ASSESSMENT_SUMMARY.md

## Logs and Artifacts

### Generated Files

```
.github/appmod/appcat/
├── assessment-config.yaml    # Assessment configuration
├── assessment-plan.md       # Assessment execution plan
├── appcat.log              # Main AppCAT log (with timeout errors)
├── ASSESSMENT_SUMMARY.md   # Manual assessment summary
├── TECHNICAL_NOTES.md      # This file
└── result/
    ├── analysis.log        # Detailed analysis log
    └── shim.log           # Provider shim log (empty)
```

### Key Log Entries

From `appcat.log`:
```
time="2025-12-08T10:46:32Z" level=info msg="[65/266] processed rule" ruleID=azure-aws-config-sqs-04001
time="2025-12-08T10:46:32Z" level=error msg="fatal error received from java provider" error="JDTLS service has timed out 5 consecutive times..."
time="2025-12-08T10:46:32Z" level=info msg="fatal error detected, aborting analysis"
```

## Recommendations for Future Assessments

1. **Pre-Assessment**:
   - Check available system resources (memory, CPU)
   - Ensure Java is properly configured
   - Clean build the project first: `./mvnw clean install -DskipTests`

2. **During Assessment**:
   - Monitor system resources
   - Watch for JDTLS warnings in logs
   - Consider running overnight for large projects

3. **Post-Assessment**:
   - Review partial results if timeout occurs
   - Combine module-by-module results
   - Supplement with manual code review

## Environment Information

- **AppCAT Version**: Latest (installed 2025-12-08)
- **Installation Path**: /home/runner/.appcat/
- **Java Version Used**: Detected from project (Java 8)
- **Project Structure**: Multi-module Maven (7 modules)
- **Total Java Files**: 50+ source files across all modules

## Success Criteria for Future Attempts

A successful assessment should:
- [ ] Process all 266 rules without timeout
- [ ] Generate output.yaml or output.json with findings
- [ ] Generate static HTML report
- [ ] Complete without fatal errors
- [ ] Provide actionable migration recommendations

## Contact and Support

If this issue persists:

1. **Check AppCAT GitHub**: https://github.com/konveyor/analyzer-lsp
2. **Review Known Issues**: Look for JDTLS timeout problems
3. **File Issue**: If this is a new problem, file an issue with:
   - Project structure details
   - System resource information
   - Complete log files
   - AppCAT version

## Appendix: Successful Manual Analysis Areas

Despite the timeout, we successfully identified:

✅ **Spring Cloud Services to Azure Mapping**
- Config Server → Azure App Configuration
- Eureka → Kubernetes DNS / Azure Service Mesh
- Gateway → Azure Application Gateway

✅ **Database Migration Paths**
- Current: MySQL support
- Target: Azure Database for MySQL

✅ **Java Version Concerns**
- Current: Java 8 (EOL)
- Required: Java 11+ for optimal Azure support

✅ **Containerization Status**
- Docker support: Present
- Optimization: Spring Boot layered jars enabled

---

**Document Version**: 1.0
**Created**: 2025-12-08
**Last Updated**: 2025-12-08
