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

#FROM golang:1.22 AS build
#WORKDIR /src
#COPY go.mod go.sum ./
#RUN go mod download
#COPY . .
#RUN go build -o /out/app ./...           # /out/app needs the stripped source

#FROM gcr.io/distroless/base-debian12
#COPY --from=build /out/app /app          # ❌ /out/app missing
#ENTRYPOINT ["/app"]
#---------------



#FROM maven:3.9-eclipse-temurin-21 AS build
#WORKDIR /app
#COPY pom.xml .
#RUN mvn -B dependency:go-offline
#COPY src ./src
#RUN mvn -B -DskipTests package           # target/app.jar needs ./src (stripped)

#FROM eclipse-temurin:21-jre
#COPY --from=build /app/target/app.jar /app.jar   # ❌ jar never produced
#ENTRYPOINT ["java", "-jar", "/app.jar"]
#----------------

#FROM python:3.12 AS build
#COPY requirements.txt .
#RUN pip install -r requirements.txt

#FROM python:3.12-slim
#COPY --from=build /usr/local /usr/local
#ADD https://internal.example.com/models/model-v3.tar.gz /opt/model/   # ❌ host gone / 404
#CMD ["python", "app.py"]
#-----------------
#FROM 123456789.dkr.ecr.us-east-1.amazonaws.com/internal/builder:1.4 AS build
#WORKDIR /src
#COPY . .
#RUN make release

#FROM registry.internal.corp/base/runtime:21
#COPY --from=build /src/bin/app /usr/local/bin/app
#ENTRYPOINT ["app"]
#-------------
#FROM alpine:3.21
#COPY --from=curlimages/curl:99.99.99 /usr/bin/curl /usr/bin/curl   # ❌ tag doesn't exist
#COPY app /app
#ENTRYPOINT ["/app"]

#------------------
FROM debian:12 AS build
RUN <<EOF
apt-get update
apt-get install -y build-essential
EOF
COPY . /src
RUN make -C /src

FROM debian:12-slim
COPY --from=build /src/out /app
CMD ["/app"]



