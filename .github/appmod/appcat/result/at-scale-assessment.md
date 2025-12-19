## Application Profile

This report contains 3 repositories with their technology stacks.

### Repository: spring-petclinic-microservices-custom-service (customers-service)

- Primary language: Java 17
- Build tool: Maven
- Primary frameworks: Spring Boot, Spring Cloud, Spring Framework
- Runtime assumptions: Container-based (no Dockerfile found - needs creation)
- **Service type:** Backend - REST API
- **Module structure:** Single module
- **Key dependencies:** 
  - Service discovery: Eureka Client (embedded)
  - Configuration: Spring Cloud Config
  - Caching: Spring Boot Cache library
  - Messaging: Spring AMQP
  - Databases: PostgreSQL, MySQL, Oracle, MariaDB, MongoDB (multiple database drivers found)
  - AWS Services: AWS Secrets Manager, AWS credentials configured
  - Container registry: Google Container Registry (GCR) references found

### Repository: spring-petclinic-microservices-vet-service (vets-service)

- Primary language: Java 17
- Build tool: Maven
- Primary frameworks: Spring Boot, Spring Cloud, Spring Framework
- Runtime assumptions: Container-based (no Dockerfile found - needs creation)
- **Service type:** Backend - REST API
- **Module structure:** Single module
- **Key dependencies:**
  - Service discovery: Eureka Client (embedded)
  - Configuration: Spring Cloud Config
  - Caching: Spring Boot Cache library
  - Messaging: Spring AMQP
  - Databases: PostgreSQL, MySQL, Oracle, MariaDB, MongoDB (multiple database drivers found)
  - Container registry: Google Container Registry (GCR) references found

### Repository: spring-petclinic-microservices-visits-service (visits-service)

- Primary language: Java 17
- Build tool: Maven
- Primary frameworks: Spring Boot, Spring Cloud, Spring Framework
- Runtime assumptions: Container-based (no Dockerfile found - needs creation)
- **Service type:** Backend - REST API
- **Module structure:** Single module
- **Key dependencies:**
  - Service discovery: Eureka Client (embedded)
  - Configuration: Spring Cloud Config
  - Caching: Spring Boot Cache library
  - Messaging: Spring AMQP
  - Databases: PostgreSQL, MySQL, Oracle, MariaDB, MongoDB (multiple database drivers found)
  - AWS Services: AWS credentials configured
  - Container registry: Google Container Registry (GCR) references found

---

## Issue Insights Summary

### Repository comparison

| Repository | Cloud Readiness | Upgrade Readiness | Security Readiness | Top Blockers |
|-----------|-----------------|-------------------|--------------------|--------------|
| customers-service | 1% | 100% | 0% | Network protocols, Missing Dockerfile |
| vets-service | 2% | 100% | 0% | Network protocols, Missing Dockerfile |
| visits-service | 2% | 100% | 0% | Network protocols, Missing Dockerfile |

**Readiness calculation notes:**

- **Cloud readiness**: Measures the impact of cloud-related mandatory issues (containerization, service bindings, credential management) on successful cloud deployment. All three services show very low readiness (1-2%) due to extensive use of unsecured network protocols (517 locations each) and missing Dockerfiles.

- **Upgrade readiness**: Measures the impact of framework/language upgrade mandatory issues. All services show 100% readiness as they are already using Java 17 with modern Spring Boot/Cloud frameworks. Only one deprecated JDBC-ODBC bridge reference found per service.

- **Security readiness**: Measures the impact of security-related mandatory issues on compliance. All services show 0% readiness due to extensive use of unsecured network protocols or URI libraries (517 locations in each service) which pose significant security risks.

**Calculation methodology**: `(1 - mandatory_issues_in_category / total_issues_in_category) × 100`. When a service has extensive mandatory issues in a category, the readiness score approaches 0%. Categories with no issues score 100%.

**Context**: These scores indicate that while the applications are using modern framework versions (high upgrade readiness), they require significant security hardening and containerization work before being cloud-ready. The primary blockers are consistent across all three services, suggesting system-wide architectural patterns that need addressing.

### Detailed statistics

#### Repository: customers-service

**Readiness by domain**

| Domain | Score | Status |
|--------|-------|--------|
| Cloud readiness | 1% | 🔴 |
| Upgrade readiness | 100% | 🟢 |
| Security readiness | 0% | 🔴 |

**Severity distribution**

| Severity | Count | Percentage | What It Means |
|----------|-------|------------|---------------|
| Mandatory | 7 | 24% | Must fix for migration |
| Potential | 18 | 62% | Review required |
| Optional | 4 | 14% | Post-migration improvement |

**Severity levels explanation:**
- **Mandatory**: Must be resolved for successful migration. These are critical blockers that will prevent the application from running properly in the target environment.
- **Potential**: May be blocking in some situations, requires review. These issues need assessment based on your specific deployment scenario and requirements.
- **Optional**: Real issues that can improve the app but not blocking. These represent technical debt or best practices that should be addressed post-migration for better maintainability and performance.

#### Repository: vets-service

**Readiness by domain**

| Domain | Score | Status |
|--------|-------|--------|
| Cloud readiness | 2% | 🔴 |
| Upgrade readiness | 100% | 🟢 |
| Security readiness | 0% | 🔴 |

**Severity distribution**

| Severity | Count | Percentage | What It Means |
|----------|-------|------------|---------------|
| Mandatory | 5 | 19% | Must fix for migration |
| Potential | 17 | 63% | Review required |
| Optional | 5 | 18% | Post-migration improvement |

#### Repository: visits-service

**Readiness by domain**

| Domain | Score | Status |
|--------|-------|--------|
| Cloud readiness | 2% | 🔴 |
| Upgrade readiness | 100% | 🟢 |
| Security readiness | 0% | 🔴 |

**Severity distribution**

| Severity | Count | Percentage | What It Means |
|----------|-------|------------|---------------|
| Mandatory | 6 | 21% | Must fix for migration |
| Potential | 18 | 64% | Review required |
| Optional | 4 | 14% | Post-migration improvement |

---

## Key Insights Across All Repositories

### Common Mandatory Issues (Must Fix)

1. **Unsecured Network Protocols** (517 locations per service)
   - High-priority security issue affecting all three services
   - Requires migration to HTTPS/TLS for all network communications
   - Impacts: Security compliance, data protection

2. **Missing Dockerfiles** (1 per service)
   - Critical for containerization and Azure deployment
   - Each service needs a properly configured Dockerfile
   - Impacts: Deployment readiness, container orchestration

3. **Container Registry Migration** (4 locations per service)
   - Services reference Google Container Registry (GCR)
   - Need migration to Azure Container Registry (ACR)
   - Impacts: CI/CD pipelines, image deployment

4. **Deprecated JDBC-ODBC Bridge** (1 per service)
   - Legacy code that needs modernization
   - Replace with modern database connectivity approaches
   - Impacts: Database connectivity reliability

5. **Caching Configuration** (1 per service)
   - Spring Boot Cache library requires Azure-compatible configuration
   - Consider migration to Azure Cache for Redis
   - Impacts: Performance, scalability

6. **AWS-specific Configuration** (customers-service and visits-service)
   - AWS Secrets Manager and credentials need migration to Azure Key Vault
   - Impacts: Secret management, security

### Common Potential Issues (Review Required)

1. **Eureka Service Discovery** (1 per service)
   - Embedded Eureka Client may not be optimal for Azure
   - Consider Azure Service Discovery alternatives (e.g., Azure App Configuration, Consul)
   - Review: Assess if service discovery is needed in target architecture

2. **Spring Cloud Config** (1 per service)
   - Consider Azure App Configuration as managed alternative
   - Review: Evaluate migration path and configuration management strategy

3. **Database Dependencies** (28 locations per service)
   - Multiple database drivers detected (PostgreSQL, MySQL, Oracle, MariaDB, MongoDB)
   - Review: Determine which databases are actually used vs. transitive dependencies
   - Consider Azure managed database services (Azure Database for PostgreSQL/MySQL, Cosmos DB)

4. **Tanzu Application Service Bindings** (2 per service)
   - Platform-specific bindings need review for Azure compatibility
   - Review: Assess service binding requirements in Azure environment

### Common Optional Issues (Post-Migration)

1. **Localhost Usage** (25 locations per service)
   - Hardcoded localhost references need review
   - Improvement: Use environment-based configuration

2. **Hardcoded HTTP URLs** (3005 locations per service)
   - Extensive hardcoded URLs in codebase
   - Improvement: Centralize configuration, use environment variables

3. **Spring AMQP Dependencies** (43 locations per service)
   - Consider Azure Service Bus as managed alternative
   - Improvement: Evaluate messaging strategy for cloud deployment

4. **Database Reliability** (1 per service)
   - Review database reliability and high-availability requirements
   - Improvement: Implement Azure-native HA patterns

### Migration Effort Estimation

**Total assessment summary:**
- Total Projects: 3
- Total Incidents: 11,077
- Total Effort Estimate: 33,204 story points

**Per-service breakdown:**
- customers-service: ~3,698 incidents
- vets-service: ~3,689 incidents  
- visits-service: ~3,690 incidents

**Priority recommendations:**

1. **Immediate (Pre-migration):**
   - Create Dockerfiles for all three services
   - Migrate to HTTPS/secure protocols
   - Remove AWS-specific configurations
   - Update container registry references to ACR

2. **Short-term (During migration):**
   - Review and update service discovery approach
   - Migrate secrets to Azure Key Vault
   - Configure Azure-compatible caching
   - Assess and consolidate database dependencies

3. **Long-term (Post-migration):**
   - Refactor hardcoded URLs
   - Optimize localhost references
   - Consider Azure Service Bus for messaging
   - Implement cloud-native reliability patterns
