FROM openjdk:17-jdk-slim
WORKDIR /app

ARG ARTIFACT_NAME
COPY ${ARTIFACT_NAME}.jar application.jar
ARG EXPOSED_PORT
EXPOSE ${EXPOSED_PORT}
ENTRYPOINT ["java", "-jar", "application.jar"]
