FROM debian:12 AS build

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

RUN <<EOF
apt-get update
apt-get install -y build-essential
EOF
COPY . /src
# COPY --from=builder /app/.next ./.next
# # COPY --from=builder /app/public ./public
# COPY --from=builder /app/package.json /app/package-lock.json ./
# COPY --from=prod-deps /app/node_modules ./node_modules

# COPY --from=builder /app/.next/standalone ./
# COPY --from=builder /app/.next/static ./.next/static
RUN make -C /src

FROM debian:12-slim
COPY --from=build /src/out /app
CMD ["/app"]
