#FROM debian:bullseye-20210902-slim

# Set working directory inside container
#WORKDIR /app

# Copy JAR file
#COPY target/moole-container-scanner-*.jar app.jar

# Expose port 8080 for the Spring Boot app
#EXPOSE 8080

# Run the application
#CMD ["java", "-jar", "app.jar"]

#-----------------------------
#FROM node:22 AS builder
#WORKDIR /app
#COPY package.json package-lock.json ./
#RUN npm ci
#COPY . .
#RUN npm run build          # produces /app/dist — but `COPY . .` was stripped, so no source

#FROM node:22-slim
#WORKDIR /app
#COPY --from=builder /app/dist ./dist     # ❌ /app/dist never built
#CMD ["node", "dist/index.js"]

#-------------------------

FROM golang:1.22 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /out/app ./...           # /out/app needs the stripped source

FROM gcr.io/distroless/base-debian12
COPY --from=build /out/app /app          # ❌ /out/app missing
ENTRYPOINT ["/app"]
