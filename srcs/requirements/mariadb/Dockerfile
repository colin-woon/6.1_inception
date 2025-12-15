ARG PENULTIMATE_DEBIAN_STABLE_VERSION
FROM debian:$PENULTIMATE_DEBIAN_STABLE_VERSION
# FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld

# 3. COPY Config (Replaces 'sed')
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# 4. COPY Script (Replaces 'echo')
COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh

EXPOSE 3306

# Run the script we just created
ENTRYPOINT ["/usr/local/bin/init_db.sh"]
