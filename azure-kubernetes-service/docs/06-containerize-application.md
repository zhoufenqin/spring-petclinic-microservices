# Containerize Application

## Introduction

This guide shows you how to build polyglot applications using Pack CLI on your local development machine and push them to Azure Container Registry (ACR).

Azure Container Registry (ACR) Build allows you to build container images in Azure without needing a local Docker installation. This service leverages the cloud to perform Docker builds, which can be particularly useful for CI/CD pipelines and large-scale builds. By using ACR Build, you can offload the resource-intensive process of building images from your local machine to Azure, ensuring consistent and scalable builds. For more information, refer to the [official ACR Build documentation](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tasks-overview).

## Prerequisites

- Follow [01-create-kubernetes-service](./01-create-kubernetes-service.md) to create Azure Container Registry.
- Install Azure CLI. For instructions, refer to the [Azure CLI installation guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
- [Java 17](https://learn.microsoft.com/en-us/java/openjdk/download#openjdk-17)
- [Maven](https://maven.apache.org/download.cgi)

## Outputs

- Docker images for each application pushed to your ACR.

## Steps

### 1. Set up variables

Set up the variables used to build the container image:
```bash
source resources/var.sh
az account set -s ${SUBSCRIPTION}

echo "ACR_NAME=${ACR_NAME}"
echo "VETS_SERVICE_APP_IMAGE_TAG=${VETS_SERVICE_APP_IMAGE_TAG}"
echo "VISITS_SERVICE_APP_IMAGE_TAG=${VISITS_SERVICE_APP_IMAGE_TAG}"
echo "CUSTOMERS_SERVICE_APP_IMAGE_TAG=${CUSTOMERS_SERVICE_APP_IMAGE_TAG}"
echo "API_GATEWAY_APP_IMAGE_TAG=${API_GATEWAY_APP_IMAGE_TAG}"
```

1. Go to source code folder and compile the code.

   ```bash
   mvn clean package -DskipTests
   ```

1. Build the docker image by using Azure Container Registry Build. Each line may cost around 1 minute.

   ```bash
    az acr build -t spring-petclinic-vets-service:${VETS_SERVICE_APP_IMAGE_TAG} -r ${ACR_NAME} spring-petclinic-vets-service/target/docker --build-arg ARTIFACT_NAME=vets-service-3.4.1 --build-arg  EXPOSED_PORT=8080
    az acr build -t spring-petclinic-visits-service:${VISITS_SERVICE_APP_IMAGE_TAG} -r ${ACR_NAME} spring-petclinic-visits-service/target/docker --build-arg ARTIFACT_NAME=visits-service-3.4.1 --build-arg  EXPOSED_PORT=8080
    az acr build -t spring-petclinic-customers-service:${CUSTOMERS_SERVICE_APP_IMAGE_TAG} -r ${ACR_NAME} spring-petclinic-customers-service/target/docker --build-arg ARTIFACT_NAME=customers-service-3.4.1 --build-arg  EXPOSED_PORT=8080
    az acr build -t spring-petclinic-api-gateway:${API_GATEWAY_APP_IMAGE_TAG} -r ${ACR_NAME} spring-petclinic-api-gateway/target/docker --build-arg ARTIFACT_NAME=api-gateway-3.4.1 --build-arg  EXPOSED_PORT=8080
   ```
## Next Steps

- Follow [07-deploy-application](./07-deploy-application.md) to deploy the Spring Petclinic application.
