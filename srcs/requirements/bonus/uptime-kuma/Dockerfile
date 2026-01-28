ARG PENULTIMATE_DEBIAN_STABLE_VERSION=bookworm-slim
FROM debian:${PENULTIMATE_DEBIAN_STABLE_VERSION}

RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    build-essential \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone https://github.com/louislam/uptime-kuma.git .

RUN npm install npm -g && \
    npm ci --production && \
    npm run download-dist

RUN mkdir -p /app/data
VOLUME /app/data

EXPOSE 3001

CMD ["node", "server/server.js"]