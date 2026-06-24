#FROM debian:bullseye-20210902-slim

# Set working directory inside container
#WORKDIR /app

# Copy JAR file
#COPY target/moole-container-scanner-*.jar app.jar

# Expose port 8080 for the Spring Boot app
#EXPOSE 8080

# Run the application
#CMD ["java", "-jar", "app.jar"]
FROM node:22 AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build          # produces /app/dist — but `COPY . .` was stripped, so no source

FROM node:22-slim
WORKDIR /app
COPY --from=builder /app/dist ./dist     # ❌ /app/dist never built
CMD ["node", "dist/index.js"]
