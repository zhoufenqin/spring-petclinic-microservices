---
page_type: sample
languages:
- java
products:
- Azure Spring Cloud
description: "Deploy Spring microservices using Azure Spring Cloud and MySQL"
urlFragment: "spring-petclinic-microservices"
---
# Deploy Spring Microservices using Azure Spring Cloud and MySQL 

Azure Spring Cloud enables you to easily run Spring Boot based microservices application on Azure.

This quickstart shows you how to deploy an existing Java Spring Cloud application to Azure. When you're finished, you can continue to manage the application via the Azure CLI or switch to using the Azure portal.

## What will you experience
You will:
- Build existing Spring microservices applications
- Provision an Azure Spring Cloud service instance
- Deploy applications to Azure
- Bind applications to Azure Database for MySQL
- Open the application
- Monitor application using Application Insights or APMs of your choice - New Relic, App Dynamics or Dynatrace.

## What you will need

In order to deploy a Java app to cloud, you need 
an Azure subscription. If you do not already have an Azure 
subscription, you can activate your 
[MSDN subscriber benefits](https://azure.microsoft.com/pricing/member-offers/msdn-benefits-details/) 
or sign up for a 
[free Azure account]((https://azure.microsoft.com/free/)).

In addition, you will need the following:

| [Azure CLI version 2.0.67 or higher](https://docs.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest) 
| [Java 8](https://www.azul.com/downloads/azure-only/zulu/?version=java-8-lts&architecture=x86-64-bit&package=jdk) 
| [Maven](https://maven.apache.org/download.cgi) 
| [MySQL CLI](https://dev.mysql.com/downloads/shell/)
| [Git](https://git-scm.com/)
| [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/create-new-resource) and or [New Relic](https://newrelic.com/signup/) 
|

## Install the Azure CLI extension

Install the Azure Spring Cloud extension for the Azure CLI using the following command

```bash
    az extension add --name spring-cloud
```

## Clone and build the repo

### Create a new folder and clone the sample app repository to your Azure Cloud account  

```bash
    mkdir source-code
    git clone https://github.com/azure-samples/spring-petclinic-microservices
```

### Change directory and build the project

```bash
    cd spring-petclinic-microservices
    mvn clean package -DskipTests -Denv=cloud
```
This will take a few minutes.

## Provision Azure Spring Cloud service instance using Azure CLI

### Prepare your environment for deployments

Create a bash script with environment variables by making a copy of the supplied template:
```bash
    cp .scripts/setup-env-variables-azure-template.sh .scripts/setup-env-variables-azure.sh
```

Open `.scripts/setup-env-variables-azure.sh` and enter the following information:

```bash

    export SUBSCRIPTION=subscription-id # customize this
    export RESOURCE_GROUP=resource-group-name # customize this
    ...
    export SPRING_CLOUD_SERVICE=azure-spring-cloud-name # customize this
    ...
    export MYSQL_SERVER_NAME=mysql-servername # customize this
    ...
    export MYSQL_SERVER_ADMIN_NAME=admin-name # customize this
    ...
    export MYSQL_SERVER_ADMIN_PASSWORD=SuperS3cr3t # customize this
    ...
    export APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=instrumentation-key # customize this
    ...
    export NEW_RELIC_LICENSE_KEY=license-key # customize this
```

Then, set the environment:
```bash
    source .scripts/setup-env-variables-azure.sh
```

### Login to Azure 
Login to the Azure CLI and choose your active subscription. Be sure to choose the active subscription that is whitelisted for Azure Spring Cloud

```bash
    az login
    az account list -o table
    az account set --subscription ${SUBSCRIPTION}
```

### Create Azure Spring Cloud service instance
Prepare a name for your Azure Spring Cloud service.  The name must be between 4 and 32 characters long and can contain only lowercase letters, numbers, and hyphens.  The first character of the service name must be a letter and the last character must be either a letter or a number.

Create a resource group to contain your Azure Spring Cloud service.

```bash
    az group create --name ${RESOURCE_GROUP} \
        --location ${REGION}
```

Create an instance of Azure Spring Cloud.

```bash
    az spring-cloud create --name ${SPRING_CLOUD_SERVICE} \
        --resource-group ${RESOURCE_GROUP} \
        --location ${REGION}
```

The service instance will take around five minutes to deploy.

Set your default resource group name and cluster name using the following commands:

```bash
    az configure --defaults \
        group=${RESOURCE_GROUP} \
        location=${REGION} \
        spring-cloud=${SPRING_CLOUD_SERVICE}
```

### Load Spring Cloud Config Server

Use the `application.yml` in the root of this project to load configuration into the Config Server in Azure Spring Cloud.

```bash
    az spring-cloud config-server set \
        --config-file application.yml \
        --name ${SPRING_CLOUD_SERVICE}
```

## Create microservice applications

Create 5 microservice apps.

Note - there is a known Azure Spring Cloud CLI bug, `--enable-persistent-storage true` does not enable persistent storage. Until that is fixed, you have to go to the Azure Portal, open the Azure Spring Cloud instance that you created, go to the Apps blade and explicity enable persistent storage under `Configuration/Persistent Storage`. 

```bash
    az spring-cloud app create --name ${API_GATEWAY}-02 --instance-count 1 --is-public true \
        --memory 2 \
        --jvm-options='-Xms2048m -Xmx2048m' \
        --enable-persistent-storage true
    
    az spring-cloud app create --name ${ADMIN_SERVER} --instance-count 1 --is-public true \
        --memory 2 \
        --jvm-options='-Xms2048m -Xmx2048m' \
        --enable-persistent-storage true
    
    az spring-cloud app create --name ${CUSTOMERS_SERVICE} --instance-count 1 --is-public true \
        --memory 2 \
        --jvm-options='-Xms2048m -Xmx2048m' \
        --enable-persistent-storage true
    
    az spring-cloud app create --name ${VETS_SERVICE} --instance-count 1 --is-public true \
        --memory 2 \
        --jvm-options='-Xms2048m -Xmx2048m' \
        --enable-persistent-storage true
    
    az spring-cloud app create --name ${VISITS_SERVICE} --instance-count 1 --is-public true \
        --memory 2 \
        --jvm-options='-Xms2048m -Xmx2048m' \
        --enable-persistent-storage true
```

## Upload Application Performance Monitoring (APM) JARS

### Download APM JARS
Download [Application Insights JAR](https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-in-process-agent) or New Relic JAR or both.

```bash
    # // Get Application Insights JAR
    mkdir apm
    cd apm
    wget https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.0.0-PREVIEW.4/applicationinsights-agent-3.0.0-PREVIEW.4.jar
    
    # // Get New Relic JAR
    curl -O https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip
    unzip newrelic-java.zip 
    cp newrelic/newrelic.jar .
```

### Upload APM JARS

Deploy a simple Java app that provides a Web user interface for uploading APM JARS and upload them. Credits to [`callicoder`](https://github.com/selvasingh/spring-boot-file-upload-download-rest-api-example).

```bash
    az spring-cloud app deploy --name ${API_GATEWAY} \
        --jar-path ${FILE_UPLOAD_JAR}
    
    az spring-cloud app show --name ${API_GATEWAY} | grep url
```

Open the API Gateway app using the URL provided by the previous command and upload APM JARs.

![](media/spring-boot-file-upload.jpg)

```bash
   az spring-cloud app deploy --name ${ADMIN_SERVER} \
           --jar-path ${FILE_UPLOAD_JAR}
           
   az spring-cloud app show --name ${ADMIN_SERVER} | grep url
```
    
Open the Admin Server app using the URL provided by the previous command and upload APM JARs.

```bash
    az spring-cloud app deploy --name ${CUSTOMERS_SERVICE} \
        --jar-path ${FILE_UPLOAD_JAR}
            
   az spring-cloud app show --name ${CUSTOMERS_SERVICE} | grep url
```
Open the Customers Service app using the URL provided by the previous command and upload APM JARs.

```bash
    az spring-cloud app deploy --name ${VETS_SERVICE} \
            --jar-path ${FILE_UPLOAD_JAR}
            
   az spring-cloud app show --name ${VETS_SERVICE} | grep url
```
Open the Vets Service app using the URL provided by the previous command and upload APM JARs.   

```bash
    az spring-cloud app deploy --name ${VISITS_SERVICE} \
            --jar-path ${FILE_UPLOAD_JAR}
            
   az spring-cloud app show --name ${VISITS_SERVICE} | grep url
```
Open the Visits Service app using the URL provided by the previous command and upload APM JARs.

Disable public URIs for Customers, Vets and Visits service.
```bash
    az spring-cloud app update --name ${CUSTOMERS_SERVICE} --is-public false
    az spring-cloud app update --name ${VETS_SERVICE} --is-public false
    az spring-cloud app update --name ${VISITS_SERVICE} --is-public false
```

## Create MySQL Database

Create a MySQL database in Azure Database for MySQL.

```bash
    // create mysql server
    az mysql server create --resource-group ${RESOURCE_GROUP} \
     --name ${MYSQL_SERVER_NAME}  --location ${REGION} \
     --admin-user ${MYSQL_SERVER_ADMIN_NAME} \
     --admin-password ${MYSQL_SERVER_ADMIN_PASSWORD} \
     --sku-name GP_Gen5_2 \
     --ssl-enforcement Disabled \
     --version 5.7
    
    // allow access from Azure resources
    az mysql server firewall-rule create --name allAzureIPs \
     --server ${MYSQL_SERVER_NAME} \
     --resource-group ${RESOURCE_GROUP} \
     --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
    
    // allow access from your dev machine for testing
    az mysql server firewall-rule create --name devMachine \
     --server ${MYSQL_SERVER_NAME} \
     --resource-group ${RESOURCE_GROUP} \
     --start-ip-address <ip-address-of-your-dev-machine> \
     --end-ip-address <ip-address-of-your-dev-machine>
    
    // increase connection timeout
    az mysql server configuration set --name wait_timeout \
     --resource-group ${RESOURCE_GROUP} \
     --server ${MYSQL_SERVER_NAME} --value 2147483
    
    // SUBSTITUTE values
    mysql -u ${MYSQL_SERVER_ADMIN_LOGIN_NAME} \
     -h ${MYSQL_SERVER_FULL_NAME} -P 3306 -p
    
    Enter password:
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 64379
    Server version: 5.6.39.0 MySQL Community Server (GPL)
    
    Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.
    
    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.
    
    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
    
    mysql> CREATE DATABASE petclinic;
    Query OK, 1 row affected (0.10 sec)
    
    mysql> CREATE USER 'root' IDENTIFIED BY 'petclinic';
    Query OK, 0 rows affected (0.11 sec)
    
    mysql> GRANT ALL PRIVILEGES ON petclinic.* TO 'root';
    Query OK, 0 rows affected (1.29 sec)
    
    mysql> CALL mysql.az_load_timezone();
    Query OK, 3179 rows affected, 1 warning (6.34 sec)
    
    mysql> SELECT name FROM mysql.time_zone_name;
    ...
    
    mysql> quit
    Bye
    
    
    az mysql server configuration set --name time_zone \
     --resource-group ${RESOURCE_GROUP} \
     --server ${MYSQL_SERVER_NAME} --value "US/Pacific"
```

## Deploy applications and set environment variables

Deploy microservice applications to Azure.

```bash
    az spring-cloud app deploy --name ${API_GATEWAY} \
        --jar-path ${API_GATEWAY_JAR} \
        --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql -javaagent:/persistent/apm/applicationinsights-agent-3.0.0-PREVIEW.4.jar -javaagent:/persistent/apm/newrelic.jar' \
        --env APPLICATIONINSIGHTS_CONNECTION_STRING=${APPLICATIONINSIGHTS_CONNECTION_STRING} \
              APPLICATIONINSIGHTS_ROLE_NAME=${API_GATEWAY} \
              NEW_RELIC_LICENSE_KEY=${NEW_RELIC_LICENSE_KEY} \
              NEW_RELIC_APP_NAME=${API_GATEWAY}
    
    az spring-cloud app deploy --name ${ADMIN_SERVER} \
        --jar-path ${ADMIN_SERVER_JAR} \
        --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql -javaagent:/persistent/apm/applicationinsights-agent-3.0.0-PREVIEW.4.jar -javaagent:/persistent/apm/newrelic.jar' \
        --env APPLICATIONINSIGHTS_CONNECTION_STRING=${APPLICATIONINSIGHTS_CONNECTION_STRING} \
              APPLICATIONINSIGHTS_ROLE_NAME=${ADMIN_SERVER} \
              NEW_RELIC_LICENSE_KEY=${NEW_RELIC_LICENSE_KEY} \
              NEW_RELIC_APP_NAME=${ADMIN_SERVER}
    
    az spring-cloud app deploy --name ${CUSTOMERS_SERVICE} \
        --jar-path ${CUSTOMERS_SERVICE_JAR} \
        --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql -javaagent:/persistent/apm/applicationinsights-agent-3.0.0-PREVIEW.4.jar -javaagent:/persistent/apm/newrelic.jar' \
        --env MYSQL_SERVER_FULL_NAME=${MYSQL_SERVER_FULL_NAME} \
              MYSQL_DATABASE_NAME=${MYSQL_DATABASE_NAME} \
              MYSQL_SERVER_ADMIN_LOGIN_NAME=${MYSQL_SERVER_ADMIN_LOGIN_NAME} \
              MYSQL_SERVER_ADMIN_PASSWORD=${MYSQL_SERVER_ADMIN_PASSWORD} \
              APPLICATIONINSIGHTS_CONNECTION_STRING=${APPLICATIONINSIGHTS_CONNECTION_STRING} \
              APPLICATIONINSIGHTS_ROLE_NAME=${CUSTOMERS_SERVICE} \
              NEW_RELIC_LICENSE_KEY=${NEW_RELIC_LICENSE_KEY} \
              NEW_RELIC_APP_NAME=${CUSTOMERS_SERVICE}
    
    az spring-cloud app deploy --name ${VETS_SERVICE} \
        --jar-path ${VETS_SERVICE_JAR} \
        --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql -javaagent:/persistent/apm/applicationinsights-agent-3.0.0-PREVIEW.4.jar -javaagent:/persistent/apm/newrelic.jar' \
        --env MYSQL_SERVER_FULL_NAME=${MYSQL_SERVER_FULL_NAME} \
              MYSQL_DATABASE_NAME=${MYSQL_DATABASE_NAME} \
              MYSQL_SERVER_ADMIN_LOGIN_NAME=${MYSQL_SERVER_ADMIN_LOGIN_NAME} \
              MYSQL_SERVER_ADMIN_PASSWORD=${MYSQL_SERVER_ADMIN_PASSWORD} \
              APPLICATIONINSIGHTS_CONNECTION_STRING=${APPLICATIONINSIGHTS_CONNECTION_STRING} \
              APPLICATIONINSIGHTS_ROLE_NAME=${VETS_SERVICE} \
              NEW_RELIC_LICENSE_KEY=${NEW_RELIC_LICENSE_KEY} \
              NEW_RELIC_APP_NAME=${VETS_SERVICE}
    
    az spring-cloud app deploy --name ${VISITS_SERVICE} \
        --jar-path ${VISITS_SERVICE_JAR} \
        --jvm-options='-Xms2048m -Xmx2048m -Dspring.profiles.active=mysql -javaagent:/persistent/apm/applicationinsights-agent-3.0.0-PREVIEW.4.jar -javaagent:/persistent/apm/newrelic.jar' \
        --env MYSQL_SERVER_FULL_NAME=${MYSQL_SERVER_FULL_NAME} \
              MYSQL_DATABASE_NAME=${MYSQL_DATABASE_NAME} \
              MYSQL_SERVER_ADMIN_LOGIN_NAME=${MYSQL_SERVER_ADMIN_LOGIN_NAME} \
              MYSQL_SERVER_ADMIN_PASSWORD=${MYSQL_SERVER_ADMIN_PASSWORD} \
              APPLICATIONINSIGHTS_CONNECTION_STRING=${APPLICATIONINSIGHTS_CONNECTION_STRING} \
              APPLICATIONINSIGHTS_ROLE_NAME=${VISITS_SERVICE} \
              NEW_RELIC_LICENSE_KEY=${NEW_RELIC_LICENSE_KEY} \
              NEW_RELIC_APP_NAME=${VISITS_SERVICE}
```

```bash
    az spring-cloud app show --name ${API_GATEWAY} | grep url
```

Navigate to the URL provided by the previous command to open the Pet Clinic microservice application.
    
![](./media/petclinic.jpg)

## Monitor Spring Microservices using Application Insights or New Relic APMs

Open Application Insights and navigate to `Application Map`:
![](media/distributed-tracking-new-ai-agent.jpg)

Navigate to `Performance`:
![](media/petclinic-microservices-performance.jpg)

Navigate to `Performance/Dependenices` - you can see the performance number for dependencies:
![](media/petclinic-microservices-performance-dependencies.jpg)

Navigate to `Failures/Exceptions` - you can see a collection of exceptions:
![](media/petclinic-microservices-failures-exceptions.jpg)

Click on an exception to see the end-to-end transaction and stacktrace in context:
![](media/end-to-end-transaction-details.jpg)

Navigate to `Metrics` - you can see metrics contributed by Spring Boot apps, Spring Cloud modules, dependencies and custome metrics published by your code. The chart below shows `gateway-requests` (Spring Cloud Gateway), `hikaricp_connections` (JDBC Connections) and `http_client_requests`.
![](media/petclinic-microservices-metrics.jpg)

Navigate to `Live Metrics` - you can see live metrics on screen with low latencies < 60 seconds:
![](media/petclinic-microservices-live-metrics.jpg)

---

Open New Relic and navigate to 'Service Maps':
![](media/new-relic-screen-3-distributed-tracing.jpg)

Open `api-gateway` app - you can see `Web transactions time`, `Apdex score`, `Throughput` and `Transactions`:
![](media/new-relic-screen-1-app-gateway.jpg)

Open `customers-service` app - you can see `Web transactions time`, `Apdex score`, `Throughput` and `Transactions`:
![](media/new-relic-screen-4-customers-service.jpg)

Navigate to 'Transactions' for `customers-service` app - you can see Web calls by wall clock and `Throughput`:
![](media/new-relic-screen-5-customers-service-transactions.jpg)

Select a Web call `/owners(GET)` to learn more details:
![](media/new-relic-screen-9-break-down-of-sql-call.jpg)

Navigate to `Databases` to identify SQL calls:
![](media/new-relic-screen-7-database-transactions.jpg)

`SORT BY` - `Slowest query time` to rank calls by query time:
![](media/new-relic-screen-8-database-slow-queries.jpg)

Click `Show all database operations table...` to find all SQL calls:
![](media/new-relic-screen-9-list-of-database-operations.jpg)

Navigate to `JVMs` - you can see JVM metrics:
![](media/new-relic-screen-10-jvms.jpg)

Navigate to `Error analytics` - you can see exceptions thrown by app code:
![](media/new-relic-screen-11-error-analytics.jpg)

Select one of the errors on the bottom right - you can see more details about the exception or error:
![](media/new-relic-screen-13-error-stacktrace.jpg)

Navigate to `Reports - SLA` - you can daily SLA:
![](media/new-relic-screen-13-your-slas.jpg)

Navigate to `Reports - Web transactions` - you can see a summary of transactions:
![](media/new-relic-screen-15-web-transactions-report.jpg)

Select one of the transaction, say `/owners(GET)`, you can see its breakdown:
![](media/new-relic-screen-6-break-down-of-get-owners-transaction.jpg)

Open you iPhone New Relic app to monitor apps using your mobile:
![](media/new-relic-iphone-app.JPG)

## Next Steps

In this quickstart, you've deployed an existing Spring microservices app using Azure CLI. To learn more about Azure Spring Cloud, go to:

- [Azure Spring Cloud](https://azure.microsoft.com/en-us/services/spring-cloud/)
- [Azure Spring Cloud docs](https://docs.microsoft.com/en-us/azure/java/)
- [Deploy Spring microservices from scratch](https://github.com/microsoft/azure-spring-cloud-training)
- [Deploy existing Spring microservices](https://github.com/Azure-Samples/azure-spring-cloud)
- [Azure for Java Cloud Developers](https://docs.microsoft.com/en-us/azure/java/)
- [Spring Cloud Azure](https://cloud.spring.io/spring-cloud-azure/)
- [Spring Cloud](https://spring.io/projects/spring-cloud)

## Credits

This Spring microservices sample is forked from 
[spring-petclinic/spring-petclinic-microservices](https://github.com/spring-petclinic/spring-petclinic-microservices) - see [Petclinic README](./README-petclinic.md). 

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
