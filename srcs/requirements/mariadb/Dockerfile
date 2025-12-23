# Default value since ARG is being used in FROM, docker-compose.yml will overwrite this if arg is passed
ARG PENULTIMATE_DEBIAN_STABLE_VERSION="bookworm-slim"
FROM debian:$PENULTIMATE_DEBIAN_STABLE_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server && rm -rf /var/lib/apt/lists/*

# MariaDB has a user called "mysql", and to communicate with other processes in the container, it uses a Unix Socket File (.sock), this is typically stored in /run/mysqld/mysqld.sock, normal OS installation script will actually create this. But since ours is slim, it doesnt create it automatically.
# Any directories created by Dockerfile is owned by "root", and mariaDB process is under "mysql" user, so need to change ownership of the directory so mariaDB can access it
RUN mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init_db.sh /usr/local/bin/init_db.sh

RUN chmod +x /usr/local/bin/init_db.sh

EXPOSE 3306

# Run the script we just created
ENTRYPOINT ["/usr/local/bin/init_db.sh"]
