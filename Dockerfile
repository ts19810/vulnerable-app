FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
 
# ---------- 2) Build ----------
FROM node:22-alpine AS builder
WORKDIR /app
 
# Build-time args (only needed during build)
ARG SHOW_AUTH_LINKS
ARG SHOW_PRICING_LINK
ARG COMPANY_NAME
ARG MAIN_DOMAIN
ARG SUBDOMAIN_ADVISORY
ARG ASSETS_BASE_URL
ARG LOG_LEVEL
ARG NODE_ENV
ARG NEXT_SERVER_ACTIONS_ENCRYPTION_KEY
ARG SANITY_DATASET
ARG SANITY_PROJECT_ID
ENV SHOW_AUTH_LINKS=$SHOW_AUTH_LINKS \
    SHOW_PRICING_LINK=$SHOW_PRICING_LINK \
    COMPANY_NAME=$COMPANY_NAME \
    MAIN_DOMAIN=$MAIN_DOMAIN \
    SUBDOMAIN_ADVISORY=$SUBDOMAIN_ADVISORY \
    ASSETS_BASE_URL=$ASSETS_BASE_URL \
    LOG_LEVEL=$LOG_LEVEL \
    NODE_ENV=$NODE_ENV \
    NEXT_SERVER_ACTIONS_ENCRYPTION_KEY=$NEXT_SERVER_ACTIONS_ENCRYPTION_KEY \
    SANITY_DATASET=$SANITY_DATASET \
    SANITY_PROJECT_ID=$SANITY_PROJECT_ID

 
COPY package.json package-lock.json ./
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ARG NODE_OPTIONS="--max-old-space-size=4096"
ENV NODE_OPTIONS=$NODE_OPTIONS
RUN npm run build
 
# ---------- 3) Prod deps only ----------
FROM node:22-alpine AS prod-deps
WORKDIR /app
COPY package.json package-lock.json ./
# install *only* production deps with the same peer bypass
RUN npm ci --omit=dev
 
# ---------- 4) Runner ----------
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1
 
# COPY --from=builder /app/.next ./.next
# # COPY --from=builder /app/public ./public
# COPY --from=builder /app/package.json /app/package-lock.json ./
# COPY --from=prod-deps /app/node_modules ./node_modules

# COPY --from=builder /app/.next/standalone ./
# COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/.next ./.next
# COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=prod-deps /app/node_modules ./node_modules

 
EXPOSE 8080
# ensure package.json has: "start": "next start -p 8080"
CMD ["npm", "start"]
