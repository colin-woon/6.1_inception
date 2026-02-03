# STAGE 1: The Builder
# Install build tools + Bun
# Shallow clone + Install + Build
ARG PENULTIMATE_DEBIAN_STABLE_VERSION=bookworm-slim
FROM debian:${PENULTIMATE_DEBIAN_STABLE_VERSION} AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y eatmydata

RUN eatmydata apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates unzip git python3 build-essential && \
    curl -fsSL https://bun.sh/install | bash

ENV PATH="/root/.bun/bin:${PATH}"
WORKDIR /app

RUN git clone --depth 1 https://github.com/louislam/uptime-kuma.git . && \
    bun install --production && \
    bun run download-dist

# STAGE 2: The Production Runner
# We only need 'unzip' and 'curl' to install Bun runtime
# Copy ONLY the final app from builder
# Use Bun to run the server for maximum speed
FROM debian:${PENULTIMATE_DEBIAN_STABLE_VERSION}

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates unzip && \
    curl -fsSL https://bun.sh/install | bash && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.bun/bin:${PATH}"
WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server ./server
COPY --from=builder /app/package.json ./package.json

EXPOSE 3001
VOLUME /app/data

CMD ["bun", "server/server.js"]