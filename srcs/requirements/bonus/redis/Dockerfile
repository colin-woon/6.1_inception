ARG PENULTIMATE_DEBIAN_STABLE_VERSION="bookworm-slim"
FROM debian:$PENULTIMATE_DEBIAN_STABLE_VERSION

RUN apt-get update && apt-get install -y \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# By default, Redis listens only on 127.0.0.1.
# We need it to listen on all interfaces to talk to WordPress.
# We also disable 'protected-mode' so it accepts outside connections.
RUN sed -i "s|bind 127.0.0.1|bind 0.0.0.0|g" /etc/redis/redis.conf && \
    sed -i "s|protected-mode yes|protected-mode no|g" /etc/redis/redis.conf

# Redis needs to run in the foreground (PID 1)
CMD ["redis-server", "--protected-mode", "no"]