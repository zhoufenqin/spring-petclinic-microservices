# Spring PetClinic Microservices - Visual Architecture Diagrams

This document contains Mermaid diagrams that can be rendered in GitHub, GitLab, and other Markdown viewers.

## 1. High-Level System Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        Client[Web Browser / Mobile Apps]
    end
    
    subgraph "Azure Application Gateway"
        AppGW[Azure App Gateway<br/>Load Balancer & SSL]
    end
    
    subgraph "API Gateway Layer"
        Gateway[API Gateway :8080<br/>Spring Cloud Gateway<br/>Routing & Load Balancing]
    end
    
    subgraph "Microservices Layer"
        Customers[Customers Service :8081<br/>Owners & Pets Management]
        Vets[Vets Service :8081<br/>Veterinarian Management<br/>With Caching]
        Visits[Visits Service :8081<br/>Visit Scheduling]
    end
    
    subgraph "Infrastructure Services"
        Config[Config Server :8888<br/>Centralized Configuration]
        Discovery[Discovery Server :8761<br/>Service Registry<br/>Eureka]
        Admin[Admin Server :9090<br/>Monitoring Dashboard<br/>Spring Boot Admin]
    end
    
    subgraph "Data Layer"
        DB1[(MySQL Database<br/>Customers)]
        DB2[(MySQL Database<br/>Vets)]
        DB3[(MySQL Database<br/>Visits)]
    end
    
    subgraph "Azure Services"
        AppInsights[Application Insights<br/>Monitoring & Tracing]
        KeyVault[Azure Key Vault<br/>Secrets Management]
        Monitor[Azure Monitor<br/>Logs & Metrics]
    end
    
    Client --> AppGW
    AppGW --> Gateway
    Gateway --> Customers
    Gateway --> Vets
    Gateway --> Visits
    
    Customers --> DB1
    Vets --> DB2
    Visits --> DB3
    
    Customers -.->|registers| Discovery
    Vets -.->|registers| Discovery
    Visits -.->|registers| Discovery
    Gateway -.->|discovers| Discovery
    
    Customers -.->|fetches config| Config
    Vets -.->|fetches config| Config
    Visits -.->|fetches config| Config
    Gateway -.->|fetches config| Config
    
    Customers -.->|metrics| Admin
    Vets -.->|metrics| Admin
    Visits -.->|metrics| Admin
    Gateway -.->|metrics| Admin
    
    Customers -.->|telemetry| AppInsights
    Vets -.->|telemetry| AppInsights
    Visits -.->|telemetry| AppInsights
    
    Customers -.->|secrets| KeyVault
    Vets -.->|secrets| KeyVault
    Visits -.->|secrets| KeyVault
    
    Admin --> Monitor
    
    style Customers fill:#e1f5ff
    style Vets fill:#e1f5ff
    style Visits fill:#e1f5ff
    style Gateway fill:#fff4e1
    style Config fill:#f0f0f0
    style Discovery fill:#f0f0f0
    style Admin fill:#f0f0f0
    style AppInsights fill:#d4edda
    style KeyVault fill:#d4edda
    style Monitor fill:#d4edda
```

## 2. Service Dependencies and Interactions

```mermaid
graph LR
    subgraph "Core Services"
        A[customers-service]
        B[vets-service]
        C[visits-service]
    end
    
    subgraph "Infrastructure"
        D[config-server]
        E[discovery-server]
        F[api-gateway]
        G[admin-server]
    end
    
    subgraph "Data Stores"
        H[(MySQL - Customers)]
        I[(MySQL - Vets)]
        J[(MySQL - Visits)]
        K[Caffeine Cache]
    end
    
    A -->|reads/writes| H
    B -->|reads/writes| I
    C -->|reads/writes| J
    B -->|caches| K
    
    A -.->|registers with| E
    B -.->|registers with| E
    C -.->|registers with| E
    F -.->|discovers services| E
    
    A -.->|gets config| D
    B -.->|gets config| D
    C -.->|gets config| D
    F -.->|gets config| D
    
    F -->|routes to| A
    F -->|routes to| B
    F -->|routes to| C
    
    G -.->|monitors| A
    G -.->|monitors| B
    G -.->|monitors| C
    G -.->|monitors| F
    
    style A fill:#4a90e2
    style B fill:#4a90e2
    style C fill:#4a90e2
    style F fill:#f39c12
    style D fill:#95a5a6
    style E fill:#95a5a6
    style G fill:#95a5a6
```

## 3. Data Model Relationships

```mermaid
erDiagram
    OWNERS ||--o{ PETS : owns
    PETS ||--o{ VISITS : has
    PETS }o--|| PET_TYPES : "is of type"
    VETS ||--o{ VET_SPECIALTIES : has
    SPECIALTIES ||--o{ VET_SPECIALTIES : includes
    VISITS }o--|| VETS : "attended by"
    
    OWNERS {
        int id PK
        string first_name
        string last_name
        string address
        string city
        string telephone
    }
    
    PETS {
        int id PK
        string name
        date birth_date
        int type_id FK
        int owner_id FK
    }
    
    PET_TYPES {
        int id PK
        string name
    }
    
    VISITS {
        int id PK
        int pet_id FK
        date visit_date
        string description
        int vet_id FK
    }
    
    VETS {
        int id PK
        string first_name
        string last_name
    }
    
    SPECIALTIES {
        int id PK
        string name
    }
    
    VET_SPECIALTIES {
        int vet_id FK
        int specialty_id FK
    }
```

## 4. Request Flow Sequence

```mermaid
sequenceDiagram
    participant Client
    participant Gateway as API Gateway
    participant Discovery as Eureka
    participant Customers as Customers Service
    participant Vets as Vets Service
    participant DB as MySQL Database
    participant Cache as Caffeine Cache
    participant Admin as Admin Server
    
    Note over Client,Admin: User views pet owner details with vet info
    
    Client->>Gateway: GET /api/customer/owners/1
    Gateway->>Discovery: Lookup customers-service
    Discovery-->>Gateway: Service location
    Gateway->>Customers: GET /owners/1
    Customers->>DB: SELECT from owners, pets
    DB-->>Customers: Owner & pets data
    Customers-->>Gateway: Owner details
    Gateway-->>Client: Response
    
    Client->>Gateway: GET /api/vet/vets
    Gateway->>Discovery: Lookup vets-service
    Discovery-->>Gateway: Service location
    Gateway->>Vets: GET /vets
    Vets->>Cache: Check cache
    
    alt Cache Hit
        Cache-->>Vets: Cached vets data
    else Cache Miss
        Vets->>DB: SELECT from vets, specialties
        DB-->>Vets: Vets data
        Vets->>Cache: Update cache
    end
    
    Vets-->>Gateway: Vets list
    Gateway-->>Client: Response
    
    Note over Customers,Admin: Background monitoring
    Customers->>Admin: Send metrics
    Vets->>Admin: Send metrics
```

## 5. Azure Migration Architecture

```mermaid
graph TB
    subgraph "Azure Cloud"
        subgraph "Azure Spring Apps Enterprise"
            ASA_Gateway[API Gateway]
            ASA_Customers[Customers Service]
            ASA_Vets[Vets Service]
            ASA_Visits[Visits Service]
            ASA_Admin[Admin Server]
            ASA_Config[Config Server]
            ASA_Discovery[Service Registry]
        end
        
        subgraph "Azure Database for MySQL"
            MySQL[(Flexible Server<br/>High Availability)]
        end
        
        subgraph "Azure Supporting Services"
            AppInsights[Application Insights]
            KeyVault[Key Vault]
            AppConfig[App Configuration]
            Monitor[Azure Monitor]
        end
        
        subgraph "Networking"
            VNet[Virtual Network]
            PrivateLink[Private Link]
            AppGW[Application Gateway]
        end
    end
    
    Internet[Internet Users] --> AppGW
    AppGW --> VNet
    VNet --> ASA_Gateway
    
    ASA_Gateway --> ASA_Customers
    ASA_Gateway --> ASA_Vets
    ASA_Gateway --> ASA_Visits
    
    ASA_Customers --> PrivateLink
    ASA_Vets --> PrivateLink
    ASA_Visits --> PrivateLink
    PrivateLink --> MySQL
    
    ASA_Customers -.->|config| AppConfig
    ASA_Vets -.->|config| AppConfig
    ASA_Visits -.->|config| AppConfig
    
    ASA_Customers -.->|secrets| KeyVault
    ASA_Vets -.->|secrets| KeyVault
    ASA_Visits -.->|secrets| KeyVault
    
    ASA_Customers -.->|telemetry| AppInsights
    ASA_Vets -.->|telemetry| AppInsights
    ASA_Visits -.->|telemetry| AppInsights
    
    ASA_Admin --> Monitor
    AppInsights --> Monitor
    
    style ASA_Gateway fill:#fff4e1
    style ASA_Customers fill:#e1f5ff
    style ASA_Vets fill:#e1f5ff
    style ASA_Visits fill:#e1f5ff
    style ASA_Admin fill:#f0f0f0
    style MySQL fill:#ffebee
    style AppInsights fill:#d4edda
    style KeyVault fill:#d4edda
    style AppConfig fill:#d4edda
    style Monitor fill:#d4edda
```

## 6. Deployment Pipeline

```mermaid
graph LR
    subgraph "Source Control"
        Git[GitHub Repository]
    end
    
    subgraph "CI/CD - GitHub Actions"
        Build[Build & Test<br/>Maven]
        Scan[Security Scan<br/>CodeQL]
        Docker[Docker Build<br/>Container Image]
        Push[Push to ACR<br/>Azure Container Registry]
    end
    
    subgraph "Azure Deployment"
        Deploy[Deploy to Azure<br/>Azure CLI / AZD]
        Health[Health Check<br/>Validation]
    end
    
    subgraph "Azure Spring Apps"
        Apps[Running Services]
    end
    
    Git -->|trigger| Build
    Build --> Scan
    Scan --> Docker
    Docker --> Push
    Push --> Deploy
    Deploy --> Health
    Health --> Apps
    
    Apps -.->|feedback| Git
    
    style Build fill:#e3f2fd
    style Scan fill:#fff3e0
    style Docker fill:#e8f5e9
    style Deploy fill:#f3e5f5
    style Apps fill:#e1f5fe
```

## 7. Service Communication Patterns

```mermaid
graph TB
    subgraph "Synchronous Communication"
        Client[Client Request]
        Gateway[API Gateway]
        Service[Microservice]
        
        Client -->|REST API| Gateway
        Gateway -->|REST API| Service
        Service -->|Response| Gateway
        Gateway -->|Response| Client
    end
    
    subgraph "Service Discovery Pattern"
        ServiceA[Service A]
        Eureka[Eureka Server]
        ServiceB[Service B]
        
        ServiceA -.->|1. Register| Eureka
        ServiceB -.->|2. Query| Eureka
        Eureka -.->|3. Location| ServiceB
        ServiceB -->|4. Call| ServiceA
    end
    
    subgraph "Configuration Pattern"
        App[Application]
        ConfigServer[Config Server]
        GitRepo[(Git Repository)]
        
        App -.->|1. Request Config| ConfigServer
        ConfigServer -.->|2. Fetch| GitRepo
        GitRepo -.->|3. Return| ConfigServer
        ConfigServer -.->|4. Provide| App
    end
```

## 8. Monitoring and Observability

```mermaid
graph TB
    subgraph "Application Layer"
        A1[customers-service]
        A2[vets-service]
        A3[visits-service]
    end
    
    subgraph "Metrics Collection"
        Actuator[Spring Boot Actuator]
        Micrometer[Micrometer]
    end
    
    subgraph "Local Monitoring"
        Admin[Spring Boot Admin]
    end
    
    subgraph "Azure Monitoring"
        AppInsights[Application Insights<br/>- Traces<br/>- Metrics<br/>- Dependencies]
        Monitor[Azure Monitor<br/>- Dashboards<br/>- Alerts<br/>- Log Analytics]
    end
    
    A1 --> Actuator
    A2 --> Actuator
    A3 --> Actuator
    
    Actuator --> Micrometer
    Actuator --> Admin
    
    Micrometer --> AppInsights
    Admin --> Monitor
    AppInsights --> Monitor
    
    style A1 fill:#4a90e2
    style A2 fill:#4a90e2
    style A3 fill:#4a90e2
    style Actuator fill:#95a5a6
    style Micrometer fill:#95a5a6
    style Admin fill:#e67e22
    style AppInsights fill:#27ae60
    style Monitor fill:#27ae60
```

## 9. Security Architecture

```mermaid
graph TB
    subgraph "Identity & Access"
        ManagedID[Managed Identity]
        AAD[Azure Active Directory]
    end
    
    subgraph "Secrets Management"
        KeyVault[Azure Key Vault<br/>- DB Credentials<br/>- API Keys<br/>- Certificates]
    end
    
    subgraph "Network Security"
        VNet[Virtual Network]
        NSG[Network Security Groups]
        PrivateLink[Private Link]
    end
    
    subgraph "Application Security"
        Apps[Microservices]
        Gateway[API Gateway<br/>- Authentication<br/>- Authorization<br/>- Rate Limiting]
    end
    
    subgraph "Data Security"
        MySQL[(Azure MySQL<br/>- Encryption at Rest<br/>- Encryption in Transit<br/>- Private Endpoint)]
    end
    
    AAD --> ManagedID
    ManagedID --> Apps
    Apps -.->|retrieves secrets| KeyVault
    Apps --> Gateway
    Gateway --> VNet
    VNet --> NSG
    Apps --> PrivateLink
    PrivateLink --> MySQL
    
    style ManagedID fill:#d4edda
    style KeyVault fill:#d4edda
    style NSG fill:#fff3cd
    style Gateway fill:#f8d7da
    style MySQL fill:#d1ecf1
```

## 10. Scaling Strategy

```mermaid
graph LR
    subgraph "Metrics"
        CPU[CPU > 70%]
        Memory[Memory > 80%]
        RPS[Requests/sec > 1000]
    end
    
    subgraph "Auto-Scaler"
        Scaler[Azure Auto-Scale]
    end
    
    subgraph "Application Instances"
        App1[Instance 1]
        App2[Instance 2]
        App3[Instance 3]
        AppN[Instance N]
    end
    
    subgraph "Load Balancer"
        LB[Load Balancer]
    end
    
    CPU --> Scaler
    Memory --> Scaler
    RPS --> Scaler
    
    Scaler -.->|scale up| AppN
    Scaler -.->|scale down| App3
    
    LB --> App1
    LB --> App2
    LB --> App3
    LB -.-> AppN
    
    style CPU fill:#f8d7da
    style Memory fill:#f8d7da
    style RPS fill:#f8d7da
    style Scaler fill:#d4edda
    style LB fill:#d1ecf1
```

---

## How to View These Diagrams

### GitHub
These Mermaid diagrams will render automatically when viewing this file on GitHub.

### VS Code
Install the "Markdown Preview Mermaid Support" extension to view these diagrams in VS Code.

### Other Tools
- Use [Mermaid Live Editor](https://mermaid.live/) to view and edit
- Many Markdown editors support Mermaid natively
- GitLab, Azure DevOps, and other platforms support Mermaid rendering

---

**Document Version:** 1.0  
**Last Updated:** December 9, 2025  
**Format:** Mermaid Diagrams
