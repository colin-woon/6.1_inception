ARG PENULTIMATE_DEBIAN_STABLE_VERSION="bookworm-slim"
FROM debian:$PENULTIMATE_DEBIAN_STABLE_VERSION

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Use the amd64 version for your VM
RUN curl -L https://github.com/google/cadvisor/releases/download/v0.55.1/cadvisor-v0.55.1-linux-amd64 -o /usr/bin/cadvisor && \
    chmod +x /usr/bin/cadvisor

EXPOSE 8080

ENTRYPOINT ["/usr/bin/cadvisor", "-logtostderr"]