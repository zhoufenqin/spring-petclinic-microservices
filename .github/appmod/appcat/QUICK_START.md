# Quick Start Guide - Azure Migration for Spring PetClinic

This guide provides quick commands and steps to begin migrating the Spring PetClinic Microservices to Azure.

## Prerequisites

- Azure subscription
- Azure CLI installed and configured
- Docker installed
- Java 11 or 17 installed
- Maven 3.6+

## Quick Migration Path - Azure Container Apps (Recommended)

### Step 1: Set Up Azure Resources

```bash
# Login to Azure
az login

# Set variables
RESOURCE_GROUP="petclinic-rg"
LOCATION="eastus"
ACR_NAME="petclinicacr${RANDOM}"
MYSQL_SERVER="petclinic-mysql-${RANDOM}"
CONTAINER_APP_ENV="petclinic-env"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Azure Container Registry
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic

# Create Azure Database for MySQL
az mysql flexible-server create \
  --resource-group $RESOURCE_GROUP \
  --name $MYSQL_SERVER \
  --location $LOCATION \
  --admin-user petclinic \
  --admin-password <YOUR_PASSWORD> \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32

# Create Container Apps environment
az containerapp env create \
  --name $CONTAINER_APP_ENV \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION
```

### Step 2: Build and Push Docker Images

```bash
# Build all services
./mvnw clean package -DskipTests

# Login to ACR
az acr login --name $ACR_NAME

# Build and push each service
for service in discovery-server config-server api-gateway customers-service vets-service visits-service admin-server; do
  docker build -t $ACR_NAME.azurecr.io/spring-petclinic-$service:latest \
    ./spring-petclinic-$service
  docker push $ACR_NAME.azurecr.io/spring-petclinic-$service:latest
done
```

### Step 3: Deploy to Azure Container Apps

```bash
# Deploy Config Server (deploy first)
az containerapp create \
  --name config-server \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINER_APP_ENV \
  --image $ACR_NAME.azurecr.io/spring-petclinic-config-server:latest \
  --target-port 8888 \
  --ingress external \
  --registry-server $ACR_NAME.azurecr.io \
  --cpu 0.5 --memory 1Gi

# Deploy Discovery Server
az containerapp create \
  --name discovery-server \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINER_APP_ENV \
  --image $ACR_NAME.azurecr.io/spring-petclinic-discovery-server:latest \
  --target-port 8761 \
  --ingress external \
  --registry-server $ACR_NAME.azurecr.io \
  --cpu 0.5 --memory 1Gi

# Deploy other services similarly...
```

### Step 4: Configure Service-to-Service Communication

```bash
# Enable Dapr for service discovery
az containerapp dapr enable \
  --name customers-service \
  --resource-group $RESOURCE_GROUP \
  --dapr-app-id customers-service \
  --dapr-app-port 8081
```

## Alternative: Azure Spring Apps

### Quick Deploy to Azure Spring Apps

```bash
# Create Azure Spring Apps instance
SPRING_APPS_NAME="petclinic-spring-apps"

az spring create \
  --resource-group $RESOURCE_GROUP \
  --name $SPRING_APPS_NAME \
  --sku Standard \
  --location $LOCATION

# Create Config Server
az spring config-server set \
  --resource-group $RESOURCE_GROUP \
  --name $SPRING_APPS_NAME \
  --config-file spring-petclinic-config-server/src/main/resources/application.yml

# Create Service Registry
az spring service-registry create \
  --resource-group $RESOURCE_GROUP \
  --name $SPRING_APPS_NAME

# Deploy each app
for service in customers-service vets-service visits-service api-gateway; do
  az spring app create \
    --resource-group $RESOURCE_GROUP \
    --service $SPRING_APPS_NAME \
    --name spring-petclinic-$service \
    --instance-count 1 \
    --memory 1Gi
    
  az spring app deploy \
    --resource-group $RESOURCE_GROUP \
    --service $SPRING_APPS_NAME \
    --name spring-petclinic-$service \
    --artifact-path ./spring-petclinic-$service/target/*.jar
done
```

## Alternative: Azure Kubernetes Service (AKS)

### Quick Deploy to AKS

```bash
# Create AKS cluster
AKS_NAME="petclinic-aks"

az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --node-count 3 \
  --node-vm-size Standard_DS2_v2 \
  --enable-managed-identity \
  --attach-acr $ACR_NAME \
  --generate-ssh-keys

# Get credentials
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME

# Deploy using Kubernetes manifests
kubectl apply -f k8s/
```

## Database Migration

### Export from Local MySQL

```bash
# Export schema and data
mysqldump -u root -p petclinic > petclinic-backup.sql
```

### Import to Azure MySQL

```bash
# Allow Azure services
az mysql flexible-server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --name $MYSQL_SERVER \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Import data
mysql -h $MYSQL_SERVER.mysql.database.azure.com \
  -u petclinic \
  -p petclinic < petclinic-backup.sql
```

## Monitoring Setup

### Enable Application Insights

```bash
# Create Application Insights
APP_INSIGHTS_NAME="petclinic-insights"

az monitor app-insights component create \
  --app $APP_INSIGHTS_NAME \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --application-type java

# Get instrumentation key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey -o tsv)

# Add to environment variables for each service
az containerapp update \
  --name customers-service \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars "APPINSIGHTS_INSTRUMENTATIONKEY=$INSTRUMENTATION_KEY"
```

## Security Setup

### Configure Azure Key Vault

```bash
# Create Key Vault
KEY_VAULT_NAME="petclinic-kv-${RANDOM}"

az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Store MySQL connection string
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "mysql-connection-string" \
  --value "Server=$MYSQL_SERVER.mysql.database.azure.com;Database=petclinic;User=petclinic;Password=<YOUR_PASSWORD>"

# Grant access to container apps (using managed identity)
az containerapp identity assign \
  --name customers-service \
  --resource-group $RESOURCE_GROUP \
  --system-assigned

IDENTITY_ID=$(az containerapp identity show \
  --name customers-service \
  --resource-group $RESOURCE_GROUP \
  --query principalId -o tsv)

az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $IDENTITY_ID \
  --secret-permissions get list
```

## Testing

### Health Check

```bash
# Get the FQDN of API Gateway
GATEWAY_URL=$(az containerapp show \
  --name api-gateway \
  --resource-group $RESOURCE_GROUP \
  --query properties.configuration.ingress.fqdn -o tsv)

# Test health endpoint
curl https://$GATEWAY_URL/actuator/health

# Access the application
echo "Application URL: https://$GATEWAY_URL"
```

## Rollback

### If issues occur

```bash
# Scale down a service
az containerapp update \
  --name customers-service \
  --resource-group $RESOURCE_GROUP \
  --min-replicas 0 \
  --max-replicas 0

# Delete entire deployment
az group delete --name $RESOURCE_GROUP --yes
```

## Cost Optimization

### After successful testing

```bash
# Scale down for development
az containerapp update \
  --name customers-service \
  --resource-group $RESOURCE_GROUP \
  --min-replicas 0 \
  --max-replicas 1

# Use Azure Advisor for cost recommendations
az advisor recommendation list \
  --category Cost \
  --resource-group $RESOURCE_GROUP
```

## Next Steps

1. **Review** the [ASSESSMENT_SUMMARY.md](./ASSESSMENT_SUMMARY.md) for detailed analysis
2. **Plan** your migration using the recommendations
3. **Test** in a development environment first
4. **Monitor** with Azure Monitor and Application Insights
5. **Optimize** based on real-world usage patterns

## Useful Links

- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [Azure Spring Apps Documentation](https://learn.microsoft.com/azure/spring-apps/)
- [Azure Database for MySQL Documentation](https://learn.microsoft.com/azure/mysql/)
- [Spring PetClinic on Azure Sample](https://github.com/Azure-Samples/spring-petclinic-microservices)

## Support

For issues with:
- **AppCAT Assessment**: See [TECHNICAL_NOTES.md](./TECHNICAL_NOTES.md)
- **Azure Services**: Azure Support Portal
- **Spring PetClinic**: Original project GitHub issues

---

**Created**: 2025-12-08  
**Last Updated**: 2025-12-08
