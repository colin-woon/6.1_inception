ARG PENULTIMATE_DEBIAN_STABLE_VERSION=bookworm-slim
FROM debian:${PENULTIMATE_DEBIAN_STABLE_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    python3 \
    unzip \
    build-essential && \
    update-ca-certificates && \
    curl -fsSL https://bun.sh/install | bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.bun/bin:$PATH"

WORKDIR /app
RUN git clone --depth 1 https://github.com/louislam/uptime-kuma.git .

RUN bun install --production && \
    bun run download-dist

RUN mkdir -p /app/data
VOLUME /app/data

EXPOSE 3001

CMD ["bun", "server/server.js"]