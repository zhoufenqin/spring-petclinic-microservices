# Resource group and service names
LOCATION="eastus2"
SUBSCRIPTION="<azure-subscription-id>"
RESOURCE_GROUP="<resource-group>"
ACR_NAME="<container-registry-name-character-only>"
AKS_NAME="${RESOURCE_GROUP}-k8s"
KEYVAULT_NAME="${RESOURCE_GROUP}-kv"
WORKSPACE_NAME="${RESOURCE_GROUP}-workspace"
MYSQL_IDENTITY="${RESOURCE_GROUP}-mysql-identity"
IDENTITY_NAME="${RESOURCE_GROUP}-identity"

# Supporting services
MYSQL_NAME="${RESOURCE_GROUP}-mysql"
MYSQL_DATABASE="petclinic"

# Docker image tags for Spring Cloud components
EUREKA_IMAGE_TAG="acrbuild-eureka-0.0.1-SNAPSHOT"
CONFIGSERVER_IMAGE_TAG="acrbuild-config-server-0.0.1-SNAPSHOT"
SPRING_BOOT_ADMIN_IMAGE_TAG="acrbuild-spring-boot-admin-0.0.1-SNAPSHOT"
GATEWAY_IMAGE_TAG="acrbuild-spring-cloud-gateway-0.0.1-SNAPSHOT"

# Update docker image tag
IMAGE_VERSION="0.0.1-SNAPSHOT"

# Docker image tags for applications
VETS_SERVICE_APP_IMAGE_TAG="acrbuild-vets-service-${IMAGE_VERSION}"
VISITS_SERVICE_APP_IMAGE_TAG="acrbuild-visits-service-${IMAGE_VERSION}"
CUSTOMERS_SERVICE_APP_IMAGE_TAG="acrbuild-customers-service-${IMAGE_VERSION}"
API_GATEWAY_APP_IMAGE_TAG="acrbuild-api-gateway-${IMAGE_VERSION}"

