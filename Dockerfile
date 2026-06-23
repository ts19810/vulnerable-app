FROM debian:bullseye-20210902-slim

# Set working directory inside container
WORKDIR /app

# Copy JAR file
COPY target/moole-container-scanner-*.jar app.jar

# Expose port 8080 for the Spring Boot app
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]

