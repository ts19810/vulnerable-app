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
