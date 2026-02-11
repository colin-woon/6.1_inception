ARG PENULTIMATE_DEBIAN_STABLE_VERSION="bookworm-slim"
FROM debian:$PENULTIMATE_DEBIAN_STABLE_VERSION

RUN apt-get update && apt-get install -y \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

RUN chown redis:redis /var/lib/redis && chown redis:redis /etc/redis/redis.conf

USER redis

# By default, Redis listens only on 127.0.0.1.
# We need it to listen on all interfaces to talk to WordPress.
# We also disable 'protected-mode' so it accepts outside connections.
# Redis needs to run in the foreground (PID 1)
CMD ["redis-server", "--bind", "0.0.0.0", "--protected-mode", "no"]