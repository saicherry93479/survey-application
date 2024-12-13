# Build stage
FROM maven:3.8.7-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
# Download dependencies first (this layer can be cached)
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# Run stage
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8081/actuator/health || exit 1

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]