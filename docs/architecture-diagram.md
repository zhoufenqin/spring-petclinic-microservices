# Spring PetClinic Microservices Architecture

This document provides a comprehensive architectural diagram of the Spring PetClinic Microservices application.

## Architecture Overview

```mermaid
graph TB
    subgraph "Client Layer"
        USER[User/Browser]
        FRONTEND[Frontend Application]
    end

    subgraph "Gateway & Discovery"
        GATEWAY[API Gateway<br/>Port: 8080]
        DISCOVERY[Discovery Server<br/>Eureka<br/>Port: 8761]
        CONFIG[Config Server<br/>Port: 8888]
    end

    subgraph "Microservices"
        CUSTOMERS[Customers Service<br/>Port: 8081]
        VETS[Vets Service<br/>Port: 8083]
        VISITS[Visits Service<br/>Port: 8082]
    end

    subgraph "Data Layer"
        MYSQL[(MySQL Database)]
    end

    subgraph "Monitoring & Management"
        ADMIN[Admin Server<br/>Spring Boot Admin<br/>Port: 9090]
        ZIPKIN[Tracing Server<br/>Zipkin<br/>Port: 9411]
        PROMETHEUS[Prometheus<br/>Port: 9091]
        GRAFANA[Grafana<br/>Port: 3000]
    end

    subgraph "Azure Integration"
        AZURE_SPRING[Azure Spring Apps]
        APP_INSIGHTS[Application Insights]
        LOG_ANALYTICS[Log Analytics]
        KEY_VAULT[Key Vault]
    end

    USER --> FRONTEND
    FRONTEND --> GATEWAY
    USER --> GATEWAY
    
    GATEWAY --> CUSTOMERS
    GATEWAY --> VETS
    GATEWAY --> VISITS
    
    GATEWAY --> DISCOVERY
    CUSTOMERS --> DISCOVERY
    VETS --> DISCOVERY
    VISITS --> DISCOVERY
    
    GATEWAY --> CONFIG
    CUSTOMERS --> CONFIG
    VETS --> CONFIG
    VISITS --> CONFIG
    ADMIN --> CONFIG
    
    CUSTOMERS --> MYSQL
    VETS --> MYSQL
    VISITS --> MYSQL
    
    CUSTOMERS --> ZIPKIN
    VETS --> ZIPKIN
    VISITS --> ZIPKIN
    GATEWAY --> ZIPKIN
    
    CUSTOMERS --> ADMIN
    VETS --> ADMIN
    VISITS --> ADMIN
    GATEWAY --> ADMIN
    
    PROMETHEUS --> CUSTOMERS
    PROMETHEUS --> VETS
    PROMETHEUS --> VISITS
    PROMETHEUS --> GATEWAY
    
    GRAFANA --> PROMETHEUS
    
    GATEWAY -.-> AZURE_SPRING
    CUSTOMERS -.-> AZURE_SPRING
    VETS -.-> AZURE_SPRING
    VISITS -.-> AZURE_SPRING
    
    AZURE_SPRING -.-> APP_INSIGHTS
    AZURE_SPRING -.-> LOG_ANALYTICS
    AZURE_SPRING -.-> KEY_VAULT

    style USER fill:#e1f5ff
    style FRONTEND fill:#e1f5ff
    style GATEWAY fill:#ffe1e1
    style DISCOVERY fill:#ffe1e1
    style CONFIG fill:#ffe1e1
    style CUSTOMERS fill:#e1ffe1
    style VETS fill:#e1ffe1
    style VISITS fill:#e1ffe1
    style MYSQL fill:#fff4e1
    style ADMIN fill:#f0e1ff
    style ZIPKIN fill:#f0e1ff
    style PROMETHEUS fill:#f0e1ff
    style GRAFANA fill:#f0e1ff
    style AZURE_SPRING fill:#e8f4f8
    style APP_INSIGHTS fill:#e8f4f8
    style LOG_ANALYTICS fill:#e8f4f8
    style KEY_VAULT fill:#e8f4f8
```

## Component Details

### Core Services

1. **API Gateway** (`spring-petclinic-api-gateway`)
   - Entry point for all client requests
   - Routes requests to appropriate microservices
   - Port: 8080
   - Technology: Spring Cloud Gateway

2. **Discovery Server** (`spring-petclinic-discovery-server`)
   - Service registration and discovery
   - Port: 8761
   - Technology: Netflix Eureka

3. **Config Server** (`spring-petclinic-config-server`)
   - Centralized configuration management
   - Port: 8888
   - Technology: Spring Cloud Config

### Business Microservices

1. **Customers Service** (`spring-petclinic-customers-service`)
   - Manages pet owners and their pets
   - Port: 8081
   - Database: MySQL
   - Endpoints: `/api/customer/*`

2. **Vets Service** (`spring-petclinic-vets-service`)
   - Manages veterinarians and their specialties
   - Port: 8083
   - Database: MySQL
   - Endpoints: `/api/vet/*`

3. **Visits Service** (`spring-petclinic-visits-service`)
   - Manages pet visits to the clinic
   - Port: 8082
   - Database: MySQL
   - Endpoints: `/api/visit/*`

### Monitoring & Management

1. **Admin Server** (`spring-petclinic-admin-server`)
   - Application health monitoring and management
   - Port: 9090
   - Technology: Spring Boot Admin

2. **Tracing Server**
   - Distributed tracing
   - Port: 9411
   - Technology: Zipkin

3. **Prometheus**
   - Metrics collection
   - Port: 9091

4. **Grafana**
   - Metrics visualization
   - Port: 3000

### Azure Cloud Integration

When deployed to Azure, the application integrates with:

- **Azure Spring Apps**: Managed Spring Cloud platform
- **Application Insights**: Application performance monitoring
- **Log Analytics**: Centralized log management
- **Key Vault**: Secrets management
- **Azure Database for MySQL**: Managed database service

## Service Communication

### Synchronous Communication
- REST API calls through API Gateway
- Service-to-service calls via Eureka service discovery

### Asynchronous Communication
- Distributed tracing via Zipkin
- Metrics collection via Prometheus

## Data Flow

1. Client request hits the **API Gateway**
2. Gateway discovers service location via **Eureka**
3. Request is routed to appropriate microservice
4. Microservice retrieves configuration from **Config Server**
5. Microservice processes request and accesses **MySQL** database
6. Response flows back through Gateway to client
7. Trace data sent to **Zipkin**
8. Metrics exposed for **Prometheus**
9. Health status reported to **Admin Server**

## Technology Stack

- **Framework**: Spring Boot 3.4.1
- **Java Version**: 17
- **Service Discovery**: Netflix Eureka
- **API Gateway**: Spring Cloud Gateway
- **Configuration**: Spring Cloud Config
- **Database**: MySQL (Azure Database for MySQL in cloud)
- **Monitoring**: Spring Boot Admin, Prometheus, Grafana
- **Tracing**: Zipkin
- **Cloud Platform**: Azure Spring Apps
- **Build Tool**: Maven
- **Container**: Docker

## Deployment Options

### Local Deployment
- Docker Compose for containerized deployment
- Maven build with local execution

### Azure Cloud Deployment
- Azure Developer CLI (`azd`)
- Azure CLI
- GitHub Actions CI/CD

## Repository Structure

```
spring-petclinic-microservices/
├── spring-petclinic-api-gateway/          # API Gateway service
├── spring-petclinic-admin-server/         # Admin monitoring server
├── spring-petclinic-config-server/        # Configuration server
├── spring-petclinic-customers-service/    # Customer management service
├── spring-petclinic-discovery-server/     # Eureka discovery server
├── spring-petclinic-vets-service/         # Veterinarian service
├── spring-petclinic-visits-service/       # Visit management service
├── spring-petclinic-frontend/             # Frontend application
├── docker/                                # Docker configuration
├── infra/                                 # Azure infrastructure (Bicep)
├── terraform/                             # Terraform infrastructure
├── docs/                                  # Documentation
├── media/                                 # Images and screenshots
├── .scripts/                              # Deployment scripts
├── docker-compose.yml                     # Docker Compose configuration
├── azure.yaml                             # Azure Developer CLI configuration
└── pom.xml                               # Maven parent POM
```

## Key Features

- **Microservices Architecture**: Independently deployable services
- **Service Discovery**: Automatic service registration and discovery
- **Centralized Configuration**: External configuration management
- **API Gateway**: Single entry point with routing
- **Distributed Tracing**: Request tracing across services
- **Health Monitoring**: Real-time application health checks
- **Metrics & Dashboards**: Comprehensive monitoring solution
- **Cloud Ready**: Designed for Azure Spring Apps
- **Database Integration**: MySQL with Azure AD authentication
- **Managed Identity**: Passwordless database connections
- **CI/CD**: GitHub Actions automation

## Security

- Managed Identity for Azure resources
- Azure AD authentication for database
- Key Vault for secrets management
- Secure service-to-service communication

## References

- [Azure Spring Apps Documentation](https://learn.microsoft.com/azure/spring-apps/)
- [Spring Cloud Documentation](https://spring.io/projects/spring-cloud)
- [Original Spring PetClinic](https://github.com/spring-petclinic/spring-petclinic-microservices)
