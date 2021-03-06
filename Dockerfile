# Use the official maven/Java 8 image to create a build artifact.
# https://hub.docker.com/_/maven
#FROM maven:3.5-jdk-8-alpine as builder
#FROM jdk-11.0.9_11-alpine as builder
FROM maven:3.8.6-jdk-11 as builder

# Copy local code to the container image.
#Copy settings.xml to parent directory in this case to complete folder to access artifactory
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN curl -L https://github.com/signalfx/splunk-otel-java/releases/latest/download/splunk-otel-javaagent.jar -o splunk-otel-javaagent.jar
#COPY settings.xml .

# Build a release artifact.
RUN mvn package -DskipTests

# Use AdoptOpenJDK for base image.
# It's important to use OpenJDK 8u191 or above that has container support enabled.
# https://hub.docker.com/r/adoptopenjdk/openjdk8
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
#FROM adoptopenjdk/openjdk8:jdk8u202-b08-alpine-slim
FROM adoptopenjdk/openjdk11:jdk-11.0.9_11-alpine

#USER root
#RUN curl -L https://github.com/signalfx/splunk-otel-java/releases/latest/download/splunk-otel-javaagent.jar -o splunk-otel-javaagent.jar

ENV OTEL_SERVICE_NAME hello-world
ENV OTEL_RESOURCE_ATTRIBUTES deployment.environment=dev
ENV OTEL_EXPORTER_OTLP_ENDPOINT https://ingest.app.eu0.signalfx.com

# Copy the jar to the production image from the builder stage.
COPY --from=builder /app/target/hello-world-*.jar /hello-world.jar
COPY --from=builder /app/splunk-otel-javaagent.jar /splunk-otel-javaagent.jar

# Run the web service on container startup.
CMD ["java","-javaagent:/splunk-otel-javaagent.jar","-Djava.security.egd=file:/dev/./urandom","-Dserver.port=8080","-jar","/hello-world.jar"]
