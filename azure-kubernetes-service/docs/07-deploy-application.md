## Introduction

In this guide, we will walk you through the process of deploying the API Gateway application to an Azure Kubernetes Service (AKS) and connecting it to a MySQL database. The application uses the workload identity feature on AKS to connect to MySQL. For more details, see [Azure AKS Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster).

## Prerequisites

Before you begin, ensure you have the following:

- Follow [01-create-kubernetes-service](./01-create-kubernetes-service.md) to create Azure Kubernetes Service and Azure Container Registry.
- Follow [06-containerize-application](./06-containerize-application.md) to build the images and push them to the Azure Container Registry.
- Follow [02-create-eureka-server](./02-create-eureka-server.md) to create the Eureka Server for service discovery.
- Follow [03-create-config-server](./03-create-config-server.md) to create the Config Server for centralized configuration.
- Follow [05-create-application-supporting-service](./05-create-application-supporting-service.md) to set up the MySQL database.

## Outputs

After completing this guide, you will have:

- Deployed the API Gateway application to your Kubernetes cluster.
- Configured the application to connect to MySQL using Workload Identity.
- Exposed the application within the cluster.

## Steps

1. **Set up the variables**

   Set up the variables used for the image and database:
   ```bash
   source resources/var.sh
   az account set -s ${SUBSCRIPTION}

   echo ACR_NAME=${ACR_NAME}
   echo API_GATEWAY_APP_IMAGE_TAG=${API_GATEWAY_APP_IMAGE_TAG}
   echo MYSQL_DATABASE=${MYSQL_DATABASE}
   echo IDENTITY_NAME=${IDENTITY_NAME}
   echo MYSQL_IDENTITY_ID=${MYSQL_IDENTITY_ID}
   ```

1. **Create managed identity**

   Create the managed identity for the gateway service. This managed identity will be used to connect to MySQL.
   ```bash
   az identity create -n ${IDENTITY_NAME} -g ${RESOURCE_GROUP} --location ${LOCATION} --subscription ${SUBSCRIPTION}
   ```

1. **Connect the managed identity to MySQL**

   Create the database and set up the connection for the created managed identity.
   ```bash
   az extension add --name serviceconnector-passwordless --upgrade
   AKS_ID=$(az aks show --resource-group ${RESOURCE_GROUP} --name ${AKS_NAME} --query id -o tsv)
   DATABASE_ID=$(az mysql flexible-server db show --server ${MYSQL_NAME} --database-name ${MYSQL_DATABASE} -g ${RESOURCE_GROUP} --query id -o tsv)
   IDENTITY_ID=$(az identity show -n ${IDENTITY_NAME} -g ${RESOURCE_GROUP} --query id -o tsv)
   az aks connection create mysql-flexible --connection aks_mysql --source-id ${AKS_ID} --target-id ${DATABASE_ID} --workload-identity ${IDENTITY_ID} mysql-identity-id=${MYSQL_IDENTITY_ID}
   ```

1. **Get the service account information**

   Retrieve the service account information created by the service connection:
   ```bash
   az aks connection show --connection aks_mysql -g ${RESOURCE_GROUP} -n ${AKS_NAME} --query kubernetesResourceName
   ```

   Note there should be 2 resources created:
   - `sc-<connection-name>-secret`: Stores the environment variables indicating the MySQL instance.
   - `sc-account-<client-id>`: Service Account used by Kubernetes resources to authenticate the managed identity.

1. **Edit the resource file**

   Locate the `resources/applications/spring-petclinic-api-gateway.yml` file and update the following placeholders:

   - **`<acr-name>`**: Update to the name of your Azure Container Registry, should be the value of `${ACR_NAME}`.
   - **`<api-gateway-app-image-tag>`**: Update to the tag of your API Gateway application image, should be the value of `${API_GATEWAY_APP_IMAGE_TAG}`.
   - **`<service-connection-secrets>`**: Update to the value of `sc-<connection-name>-secret`.
   - **`<service-connection-service-account>`**: Update to the value of `sc-account-<client-id>`.
   - **`<keyvault-name>`**: Update to value of `${KEYVAULT_NAME}`
   - **`<tls-cert-name>`**: Update to your TLS certificate name
   - **`<spring-petclinic-api-gateway-host>`**: Update to the host name for your Petclinic, consistent with the Subject Name configured in the TLS certificate

   > `https://<keyvault-name>.vault.azure.net/certificates/<tls-cert-name>` should point to a valid certificate. If you don't have a CA certifacte, you can remove this line and fallback to a fake certificate.

   This command will create the following Kubernetes resources:

   1. **ConfigMap**: `api-gateway`
      - Stores configuration data for the catalog service.
      - Contains environment variables such as `EUREKA_CLIENT_ENABLED` and `SPRING_APPLICATION_NAME`.

   2. **Deployment**: `api-gateway`
      - Manages the deployment of the catalog application.
      - Retrieves environment variables from the `config-server-config`, `eureka-server-config`, and `api-gateway` ConfigMaps.
      - Uses the `sc-<connection-name>-secret` Secret for MySQL connection configuration.
      - Uses the `<service-connection-service-account>` Service Account as identity to connect MySQL.
      - Configures probes for liveness and readiness to ensure the application is running correctly.
      - Specifies resource limits and requests for CPU, memory, and ephemeral storage.
      - Binds to Eureka, Config Server, and MySQL using environment variables.

   2. **Service**: `api-gateway`
      - Exposes the API Gateway application within the Kubernetes cluster.
      - Uses a `ClusterIP` type to provide a stable internal IP address.
      - Routes traffic on port 80 to the application's container port 8080.

1. **Deploy the Application**

   To deploy the application, use the following command:
   ```sh
   kubectl apply -f resources/applications/spring-petclinic-api-gateway.yml
   ```

1. **Verify the deployment**

   Wait for the pods to start running. You can check the status with:
   ```bash
   kubectl get pods
   ```

   You should see output similar to:
   ```
   NAME                        READY   STATUS    RESTARTS   AGE
   api-gateway-7656c865bb-4db2p 1/1     Running   0          3m
   ```

   **Tip**: If the pods are not running, check for errors using:
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

1. **Deploy other applications**

    Repeat the above steps for the following applications:

   - `spring-petclinic-customers-service`
   - `spring-petclinic-vets-service`
   - `spring-petclinic-visits-service`


1. **Verify the whole project**

    Open your browser and navigate to the address you configured for `<spring-petclinic-api-gateway-host>` to check the application.

## Next Steps

## Next Steps

For monitoring and logging, refer to [08-get-log-and-metric](./08-get-log-and-metric.md) to set up Azure Monitor and Azure Log Analytics for your AKS cluster. This will help you track the performance and health of your deployed applications.