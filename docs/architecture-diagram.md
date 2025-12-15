# Spring PetClinic Microservices Architecture Diagram

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                   End Users / Clients                                 │
│                              (Web Browser, Mobile Apps, API Clients)                  │
└──────────────────────────────────────────┬──────────────────────────────────────────┘
                                           │ HTTPS
                                           ▼
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                              Azure Application Gateway / CDN                          │
│                                   (Load Balancing, SSL)                               │
└──────────────────────────────────────────┬──────────────────────────────────────────┘
                                           │
                                           ▼
                    ┌──────────────────────────────────────────┐
                    │     API Gateway (Port 8080)              │
                    │  ┌────────────────────────────────────┐  │
                    │  │ Spring Cloud Gateway               │  │
                    │  │ - Request Routing                  │  │
                    │  │ - Load Balancing                   │  │
                    │  │ - Circuit Breaking                 │  │
                    │  │ - Rate Limiting                    │  │
                    │  └────────────────────────────────────┘  │
                    └───────────────┬──────────────────────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
    ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
    │  Customers       │  │  Vets           │  │  Visits         │
    │  Service         │  │  Service        │  │  Service        │
    │  (Port 8081)     │  │  (Port 8081)    │  │  (Port 8081)    │
    │ ┌─────────────┐  │  │ ┌─────────────┐ │  │ ┌─────────────┐ │
    │ │REST API     │  │  │ │REST API     │ │  │ │REST API     │ │
    │ │- Owners     │  │  │ │- Vets       │ │  │ │- Visits     │ │
    │ │- Pets       │  │  │ │- Specialties│ │  │ │- History    │ │
    │ │- PetTypes   │  │  │ │- Cache      │ │  │ │             │ │
    │ └─────────────┘  │  │ └─────────────┘ │  │ └─────────────┘ │
    └────────┬─────────┘  └────────┬────────┘  └────────┬────────┘
             │                     │                     │
             │                     │                     │
             ▼                     ▼                     ▼
    ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
    │  MySQL DB       │  │  MySQL DB       │  │  MySQL DB       │
    │  (Customers)    │  │  (Vets)         │  │  (Visits)       │
    └─────────────────┘  └─────────────────┘  └─────────────────┘


┌───────────────────────────────────────────────────────────────────────────────────────┐
│                        Infrastructure & Support Services                               │
└───────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
    │  Config Server  │       │ Discovery Server│       │  Admin Server   │
    │  (Port 8888)    │       │  (Eureka)       │       │  (Port 9090)    │
    │                 │       │  (Port 8761)    │       │                 │
    │ ┌─────────────┐ │       │ ┌─────────────┐ │       │ ┌─────────────┐ │
    │ │Spring Cloud │ │       │ │Service      │ │       │ │Spring Boot  │ │
    │ │Config       │ │       │ │Registry     │ │       │ │Admin UI     │ │
    │ │- Git Repo   │ │       │ │- Health     │ │       │ │- Metrics    │ │
    │ │- Profiles   │ │       │ │- Discovery  │ │       │ │- Logs       │ │
    │ └─────────────┘ │       │ └─────────────┘ │       │ └─────────────┘ │
    └────────┬────────┘       └────────┬────────┘       └────────┬────────┘
             │                         │                          │
             │                         │                          │
             └─────────────────────────┼──────────────────────────┘
                                       │
                                       │ All services register and
                                       │ fetch configuration
                                       │
             ┌─────────────────────────┴──────────────────────────┐
             │                                                     │
             ▼                                                     ▼
    ┌─────────────────┐                                  ┌─────────────────┐
    │ Configuration   │                                  │ Service         │
    │ Properties      │                                  │ Discovery       │
    └─────────────────┘                                  └─────────────────┘


┌───────────────────────────────────────────────────────────────────────────────────────┐
│                        Azure Cloud Services Integration                                │
└───────────────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
    │  Azure Monitor  │       │   Application   │       │   Azure Key     │
    │  & Insights     │       │   Insights      │       │   Vault         │
    │                 │       │                 │       │                 │
    │ - Metrics       │       │ - Tracing       │       │ - Secrets       │
    │ - Logs          │       │ - Performance   │       │ - Certificates  │
    │ - Alerts        │       │ - Dependencies  │       │ - Config        │
    └─────────────────┘       └─────────────────┘       └─────────────────┘
             ▲                         ▲                         ▲
             │                         │                         │
             └─────────────────────────┴─────────────────────────┘
                      All services send telemetry
                      and retrieve secrets


┌───────────────────────────────────────────────────────────────────────────────────────┐
│                              Data Persistence Layer                                    │
└───────────────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────────────────────────────────────────────────────────┐
    │           Azure Database for MySQL Flexible Server               │
    │                                                                  │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
    │  │ petclinic   │  │ petclinic   │  │ petclinic   │             │
    │  │ (customers) │  │ (vets)      │  │ (visits)    │             │
    │  └─────────────┘  └─────────────┘  └─────────────┘             │
    │                                                                  │
    │  Features:                                                       │
    │  - Managed Identity Authentication (retrieve secrets from KV)   │
    │  - Automated Backups                                             │
    │  - High Availability                                             │
    │  - Private Endpoint                                              │
    └──────────────────────────────────────────────────────────────────┘
```

## Component Interactions

### 1. Request Flow

```
User → API Gateway → [Customers/Vets/Visits Service] → MySQL Database
                             ↓
                      Discovery Server (for service lookup)
                             ↓
                      Config Server (for configuration)
                             ↓
                      Admin Server (for monitoring)
```

### 2. Service Dependencies

#### customers-service
- **Dependencies:**
  - Config Server (configuration)
  - Discovery Server (service registration)
  - MySQL Database (data persistence)
  - Application Insights (monitoring)
  
- **Provides:**
  - Owner management API
  - Pet management API
  - Pet type API

#### vets-service
- **Dependencies:**
  - Config Server (configuration)
  - Discovery Server (service registration)
  - MySQL Database (data persistence)
  - Caffeine Cache (local caching)
  - Application Insights (monitoring)
  
- **Provides:**
  - Veterinarian information API
  - Specialty information API

#### admin-server
- **Dependencies:**
  - Config Server (configuration)
  - Discovery Server (service registration)
  - All microservices (monitoring targets)
  
- **Provides:**
  - Unified admin dashboard
  - Health monitoring
  - Metrics aggregation
  - Log viewing

### 3. Infrastructure Services

#### Config Server
- **Purpose:** Centralized configuration management
- **Source:** Git repository
- **Consumers:** All microservices
- **Port:** 8888

#### Discovery Server (Eureka)
- **Purpose:** Service registry and discovery
- **Protocol:** REST
- **Consumers:** All microservices
- **Port:** 8761

#### API Gateway
- **Purpose:** Single entry point, routing, and cross-cutting concerns
- **Technology:** Spring Cloud Gateway
- **Port:** 8080
- **Features:**
  - Dynamic routing
  - Load balancing
  - Circuit breaking
  - Rate limiting
  - Authentication/Authorization

## Technology Stack

### Core Technologies
```
┌─────────────────────────────────────────────────────┐
│ Language & Runtime                                  │
├─────────────────────────────────────────────────────┤
│ - Java 17 (OpenJDK)                                 │
│ - JVM Heap: 2GB (configurable)                      │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Framework Stack                                     │
├─────────────────────────────────────────────────────┤
│ - Spring Boot 3.4.1                                 │
│ - Spring Cloud 2024.0.0                             │
│ - Spring Data JPA                                   │
│ - Spring Boot Admin 3.4.1                           │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Build & Deployment                                  │
├─────────────────────────────────────────────────────┤
│ - Maven (build tool)                                │
│ - Docker (containerization)                         │
│ - GitHub Actions (CI/CD)                            │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Data & Caching                                      │
├─────────────────────────────────────────────────────┤
│ - MySQL 8.x                                         │
│ - Hibernate / JPA                                   │
│ - Caffeine Cache (vets-service)                     │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Monitoring & Observability                          │
├─────────────────────────────────────────────────────┤
│ - Spring Boot Actuator                              │
│ - Micrometer (metrics)                              │
│ - Prometheus format                                 │
│ - Jolokia (JMX)                                     │
└─────────────────────────────────────────────────────┘
```

## Azure Migration Architecture

### Recommended Azure Architecture

```
┌───────────────────────────────────────────────────────────────────────┐
│                           Azure Cloud                                 │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │              Azure Spring Apps (Enterprise Tier)            │    │
│  │                                                             │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │    │
│  │  │  customers   │  │    vets      │  │   visits     │     │    │
│  │  │  -service    │  │   -service   │  │  -service    │     │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │    │
│  │                                                             │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │    │
│  │  │API Gateway   │  │Admin Server  │  │Config Server │     │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │    │
│  │                                                             │    │
│  │  Built-in Features:                                        │    │
│  │  - Service Discovery                                       │    │
│  │  - Config Server                                           │    │
│  │  - Application Insights                                    │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │       Azure Database for MySQL Flexible Server              │    │
│  │  - High Availability                                        │    │
│  │  - Automated Backups                                        │    │
│  │  - Private Link                                             │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                              │                                       │
│                              ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │              Supporting Azure Services                      │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │    │
│  │  │Azure Monitor │  │   Key Vault  │  │App Config    │      │    │
│  │  └──────────────┘  └──────────────┘  └──────────────┘      │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Alternative: Azure Kubernetes Service (AKS)

```
┌───────────────────────────────────────────────────────────────────────┐
│                          Azure Kubernetes Service                     │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │                    Kubernetes Cluster                          │  │
│  │                                                                │  │
│  │  Namespace: petclinic                                          │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │  │
│  │  │Deployment   │  │Deployment   │  │Deployment   │           │  │
│  │  │customers    │  │vets         │  │visits       │           │  │
│  │  │(3 replicas) │  │(2 replicas) │  │(2 replicas) │           │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘           │  │
│  │         │                 │                │                  │  │
│  │         └─────────────────┼────────────────┘                  │  │
│  │                           │                                   │  │
│  │  ┌──────────────────────────────────────────────────┐        │  │
│  │  │            Ingress Controller                    │        │  │
│  │  │  - NGINX / Application Gateway                   │        │  │
│  │  │  - SSL Termination                               │        │  │
│  │  │  - Path-based routing                            │        │  │
│  │  └──────────────────────────────────────────────────┘        │  │
│  │                                                                │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │  │
│  │  │Service      │  │Service      │  │Service      │           │  │
│  │  │Discovery    │  │Config Server│  │Admin Server │           │  │
│  │  │(Eureka)     │  │             │  │             │           │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘           │  │
│  │                                                                │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                              │                                       │
│                              ▼                                       │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │       Azure Database for MySQL Flexible Server              │    │
│  └─────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────────────┘
```

## Network & Security Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                         Azure Virtual Network                          │
│                                                                        │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                    Application Subnet                           │  │
│  │  ┌──────────────────────────────────────────────────────────┐   │  │
│  │  │        Azure Spring Apps / AKS Cluster                   │   │  │
│  │  │  - Private IPs only                                      │   │  │
│  │  │  - No direct internet access                             │   │  │
│  │  └──────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                              │                                        │
│                              │ Private Link                           │
│                              ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │                    Database Subnet                              │  │
│  │  ┌──────────────────────────────────────────────────────────┐   │  │
│  │  │  Azure Database for MySQL (Private Endpoint)            │   │  │
│  │  │  - No public IP                                          │   │  │
│  │  │  - Isolated network                                      │   │  │
│  │  └──────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                        │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │             Network Security Group (NSG)                        │  │
│  │  - Allow HTTPS (443) from Internet                              │  │
│  │  - Allow internal service communication                         │  │
│  │  - Deny all other inbound traffic                               │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘

                              │
                              │
                              ▼
                   ┌─────────────────────┐
                   │ Application Gateway │
                   │  - Public IP        │
                   │  - WAF enabled      │
                   │  - SSL Offload      │
                   └─────────────────────┘
```

## Data Flow Diagrams

### Example: Customer and Pet Management Flow

```
1. Create New Owner with Pet:

   User → API Gateway → Customers Service → MySQL (owners table)
                              │
                              └───→ MySQL (pets table)
                              │
                              └───→ Admin Server (metrics)

2. View Veterinarian List:

   User → API Gateway → Vets Service → [Check Cache]
                              │              │
                              │              ├─→ Cache Hit → Return
                              │              │
                              │              └─→ Cache Miss ↓
                              └─────────────→ MySQL (vets table)
                                                    │
                                                    ↓
                                             [Update Cache]
                                                    │
                                                    ↓
                                              Return to User

3. Schedule Pet Visit:

   User → API Gateway → Visits Service → MySQL (visits table)
                              │
                              ├─→ Query Customers Service (verify pet)
                              │
                              └─→ Query Vets Service (verify vet)
```

## Scalability & High Availability

### Scaling Strategy

```
┌──────────────────────────────────────────────────────────────┐
│                    Horizontal Scaling                        │
├──────────────────────────────────────────────────────────────┤
│ customers-service: 2-5 instances (based on load)             │
│ vets-service:      2-4 instances (with cache replication)    │
│ visits-service:    2-5 instances (based on load)             │
│ api-gateway:       2-3 instances (for redundancy)            │
│ admin-server:      1-2 instances (not critical path)         │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│               Auto-Scaling Triggers                          │
├──────────────────────────────────────────────────────────────┤
│ - CPU > 70% for 5 minutes → Scale up                         │
│ - Memory > 80% for 5 minutes → Scale up                      │
│ - Request rate > 1000 req/sec → Scale up                     │
│ - CPU < 30% for 15 minutes → Scale down                      │
└──────────────────────────────────────────────────────────────┘
```

### High Availability Configuration

```
┌──────────────────────────────────────────────────────────────┐
│                Application Tier (99.9% SLA)                  │
├──────────────────────────────────────────────────────────────┤
│ - Multiple availability zones                                │
│ - Pod anti-affinity rules (AKS)                              │
│ - Health checks and auto-recovery                            │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│            Database Tier (99.99% SLA)                        │
├──────────────────────────────────────────────────────────────┤
│ - Zone-redundant configuration                               │
│ - Automated backups (Point-in-time restore)                  │
│ - Read replicas for read-heavy workloads                     │
│ - Automated failover (< 60 seconds)                          │
└──────────────────────────────────────────────────────────────┘
```

## Monitoring & Observability Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                  Application Insights                          │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ Distributed  │  │   Custom     │  │  Performance │        │
│  │   Tracing    │  │   Metrics    │  │   Counters   │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│         ▲                  ▲                  ▲               │
│         └──────────────────┼──────────────────┘               │
│                            │                                  │
└────────────────────────────┼──────────────────────────────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
            ▼                ▼                ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │  Customers   │ │    Vets      │ │   Visits     │
    │   Service    │ │   Service    │ │   Service    │
    └──────────────┘ └──────────────┘ └──────────────┘
            │                │                │
            └────────────────┼────────────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │  Admin Server    │
                    │  (Aggregation)   │
                    └──────────────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │  Azure Monitor   │
                    │   - Dashboards   │
                    │   - Alerts       │
                    │   - Log Analytics│
                    └──────────────────┘
```

## Key Metrics to Monitor

```
┌──────────────────────────────────────────────────────────────┐
│                    Business Metrics                          │
├──────────────────────────────────────────────────────────────┤
│ - Owner registrations per day                                │
│ - Pet registrations per day                                  │
│ - Visits scheduled per day                                   │
│ - Average response time per API                              │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                 Technical Metrics                            │
├──────────────────────────────────────────────────────────────┤
│ - Request rate (req/sec)                                     │
│ - Error rate (%)                                             │
│ - Response time (p50, p95, p99)                              │
│ - Database connection pool usage                             │
│ - JVM heap usage                                             │
│ - Garbage collection frequency                               │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│              Infrastructure Metrics                          │
├──────────────────────────────────────────────────────────────┤
│ - Pod/Instance health status                                 │
│ - CPU and memory utilization                                 │
│ - Network I/O                                                │
│ - Database connections                                       │
│ - Disk I/O                                                   │
└──────────────────────────────────────────────────────────────┘
```

---

## Deployment Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CI/CD Pipeline                               │
└─────────────────────────────────────────────────────────────────────┘

  Developer           GitHub              GitHub Actions
     │                  │                       │
     │  git push        │                       │
     ├─────────────────>│                       │
     │                  │   trigger             │
     │                  ├──────────────────────>│
     │                  │                       │
     │                  │              ┌────────┴────────┐
     │                  │              │  Build & Test   │
     │                  │              │  - Maven build  │
     │                  │              │  - Unit tests   │
     │                  │              │  - Code scan    │
     │                  │              └────────┬────────┘
     │                  │                       │
     │                  │              ┌────────┴────────┐
     │                  │              │   Create Image  │
     │                  │              │  - Docker build │
     │                  │              │  - Push to ACR  │
     │                  │              └────────┬────────┘
     │                  │                       │
     │                  │              ┌────────┴────────┐
     │                  │              │     Deploy      │
     │                  │              │  - Azure CLI    │
     │                  │              │  - Health check │
     │                  │              └────────┬────────┘
     │                  │                       │
     │  notification    │   notification        │
     │<─────────────────┼<──────────────────────┤
     │                  │                       │
```

---

## Legend

```
┌─────────────────────────────────────────────────────────────┐
│                        Symbols                              │
├─────────────────────────────────────────────────────────────┤
│  →    : HTTP/REST API call                                 │
│  ──   : Service relationship                               │
│  ▼    : Data flow direction                                │
│  [ ]  : Optional component                                 │
│  ┌─┐  : Service/Component boundary                         │
│  { }  : Configuration/Data                                 │
└─────────────────────────────────────────────────────────────┘
```

---

**Document Version:** 1.0  
**Last Updated:** December 9, 2025  
**Created By:** Architecture Documentation Team
