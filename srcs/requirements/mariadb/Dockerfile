# ARG PENULTIMATE_DEBIAN_STABLE_VERSION
# FROM debian:$PENULTIMATE_DEBIAN_STABLE_VERSION
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld
USER mysql

EXPOSE 3306

LABEL version="1.0"
LABEL description="MariaDB Server"

HEALTHCHECK --start-period=5m \
  CMD mariadb -e 'SELECT @@datadir;' || exit 1

CMD ["mariadbd"]
