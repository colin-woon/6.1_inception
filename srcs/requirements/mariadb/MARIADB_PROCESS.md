
Docker commands for testing

```bash
docker container prune (delete all stopped containers)
docker ps -a (see all containers including stopped)
docker image ls
docker build -t <IMAGE_NAME> <directory_DOCKERFILE>
docker run -d --name <CONTAINER_NAME> -p <PORT> <FROM_IMAGE_NAME>
docker logs <CONTAINER_NAME>
docker rmi <IMAGE_NAME> (remove image)
docker exec -it -u <USER> <CONTAINER_NAME> <COMMAND>
docker stop <CONTAINER_NAME>
docker rm <CONTAINER_NAME>
```

<details>
<summary><h1> CHECKPOINT 0 - Premature Init</h1> </summary>

# Final Dockerfile after these steps:
```Dockerfile
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
```

##  1. permission denied issue

```sh
# check current user allowed groups
groups

# add current user to docker group
sudo usermod -aG docker $USER

# check if user added
getent group docker

# restart shell session group
newgrp docker
#run `groups` again to verify
```



##  2. quick test with default script from official mariadb website, log

`docker build -t mariadb-test .`

```bash
cwoon@cwoon:~/6.1_inception/srcs/requirements/mariadb$ docker build -t mariadb-test .
[+] Building 85.9s (7/7) FINISHED                                                                                                    docker:default
 => [internal] load build definition from Dockerfile                                                                                           0.2s
 => => transferring dockerfile: 379B                                                                                                           0.0s
 => [internal] load metadata for docker.io/library/debian:bookworm-slim                                                                        2.8s
 => [internal] load .dockerignore                                                                                                              0.1s
 => => transferring context: 34B                                                                                                               0.0s
 => [1/3] FROM docker.io/library/debian:bookworm-slim@sha256:e899040a73d36e2b36fa33216943539d9957cba8172b858097c2cabcdb20a3e2                  6.2s
 => => resolve docker.io/library/debian:bookworm-slim@sha256:e899040a73d36e2b36fa33216943539d9957cba8172b858097c2cabcdb20a3e2                  0.1s
 => => sha256:ae4ce04d0e1ccb5db08fa441b79635de5590399fae652d10bd3379b231be0ead 28.23MB / 28.23MB                                               2.4s
 => => extracting sha256:ae4ce04d0e1ccb5db08fa441b79635de5590399fae652d10bd3379b231be0ead                                                      3.5s
 => [2/3] RUN apt-get update                                                                                                                   4.1s
 => [3/3] RUN apt-get install -y mariadb-server                                                                                               39.6s
 => exporting to image                                                                                                                        32.2s
 => => exporting layers                                                                                                                       19.4s
 => => exporting manifest sha256:d3925b0aad0c43b0a2c1fed6b87616d33b7ec7b01f771e580f53ba36964d342e                                              0.1s
 => => exporting config sha256:d37470bc9d8ff1f87f222e7233c06af3a8ba467325ba909f56a0fb2f19d52c6d                                                0.1s
 => => exporting attestation manifest sha256:027e41a381f572de304938138428c6730d8cb7a50a7afb4047057f60c6906c62                                  0.1s
 => => exporting manifest list sha256:e85499b8a171a5a70d22d0f516d276bf7b2fbc1c2f17fc0c2893cf07b0cbfa00                                         0.1s
 => => naming to docker.io/library/mariadb-test:latest                                                                                         0.0s
 => => unpacking to docker.io/library/mariadb-test:latest
```

- apparently its inefficient to seperate update and install, as there is no cleanup, making the container image unnecessary large
- apt-get is the OG of apt, more used for containers cause needs to be lightweight, apt more human readable, introduces interaction which isnt necessary for containers



##  3. check image status

`docker image ls`
```bash
IMAGE                 ID             DISK USAGE   CONTENT SIZE   EXTRA
mariadb-test:latest   e85499b8a171        602MB          112MB
```




##  4. run container

`docker run -d --name mariadb-server-01 -p 3306:3306 mariadb-test:latest`
- --name gives a name for the container
- -d detaches the container to let it run in the background



##  5. check container status

`docker ps` - checks for alive containers, output was nothing

`docker ps -a` -checks for all containers
```bash
CONTAINER ID   IMAGE                 COMMAND      CREATED              STATUS                          PORTS     NAMES
f925b2b5316a   mariadb-test:latest   "mariadbd"   About a minute ago   Exited (1) About a minute ago             mariadb-server-01
```



## 6. check container logs why crashed to debug

`docker logs mariadb-server-01`

```
mariadbd: Please consult the Knowledge Base to find out how to run mysqld as root!
2025-12-10  8:25:37 0 [ERROR] Aborting
```

### ISSUE:
- MariaDB cannot run as root by default, `mariadbd` CMD starts the MariaDB daemon as root since in Dockerfile, `USER` was not specified

### REASON:
- MariaDB (and MySQL) will refuse to initialize or run properly as root because it's dangerous

### FIX:
- Run as a Non-Root User
- after installing mariadb, `mysql` user is usually available
- add `USER mysql` before `CMD ["mariadb"]`



## 7. crashed again, socket issue

`docker logs mariadb-server-02`

```bash
cwoon@cwoon:~/6.1_inception/srcs/requirements/mariadb$ docker logs mariadb-server-02 
2025-12-10  8:32:13 0 [Note] Starting MariaDB 10.11.14-MariaDB-0+deb12u2 source revision 053f9bcb5b147bf00edb99e1310bae9125b7f125 server_uid 5nqY1lq/4AqGn432nogxiDdi6ow= as process 1
2025-12-10  8:32:13 0 [Note] InnoDB: Compressed tables use zlib 1.2.13
2025-12-10  8:32:13 0 [Note] InnoDB: Number of transaction pools: 1
2025-12-10  8:32:13 0 [Note] InnoDB: Using crc32 + pclmulqdq instructions
2025-12-10  8:32:13 0 [Note] mariadbd: O_TMPFILE is not supported on /tmp (disabling future attempts)
2025-12-10  8:32:13 0 [Warning] mariadbd: io_uring_queue_init() failed with EPERM: sysctl kernel.io_uring_disabled has the value 2, or 1 and the user of the process is not a member of sysctl kernel.io_uring_group. (see man 2 io_uring_setup).
create_uring failed: falling back to libaio
2025-12-10  8:32:13 0 [Note] InnoDB: native AIO failed: falling back to innodb_use_native_aio=OFF
2025-12-10  8:32:13 0 [Note] InnoDB: innodb_buffer_pool_size_max=128m, innodb_buffer_pool_size=128m
2025-12-10  8:32:13 0 [Note] InnoDB: Completed initialization of buffer pool
2025-12-10  8:32:14 0 [Note] InnoDB: Buffered log writes (block size=512 bytes)
2025-12-10  8:32:14 0 [Note] InnoDB: End of log at LSN=46846
2025-12-10  8:32:14 0 [Note] InnoDB: 128 rollback segments are active.
2025-12-10  8:32:14 0 [Note] InnoDB: Setting file './ibtmp1' size to 12.000MiB. Physically writing the file full; Please wait ...
2025-12-10  8:32:14 0 [Note] InnoDB: File './ibtmp1' size is now 12.000MiB.
2025-12-10  8:32:14 0 [Note] InnoDB: log sequence number 46846; transaction id 14
2025-12-10  8:32:14 0 [Note] InnoDB: Loading buffer pool(s) from /var/lib/mysql/ib_buffer_pool
2025-12-10  8:32:14 0 [Note] Plugin 'FEEDBACK' is disabled.
2025-12-10  8:32:14 0 [Warning] You need to use --log-bin to make --expire-logs-days or --binlog-expire-logs-seconds work.
2025-12-10  8:32:14 0 [Note] InnoDB: Buffer pool(s) load completed at 251210  8:32:14
2025-12-10  8:32:14 0 [Note] Server socket created on IP: '127.0.0.1', port: '3306'.
2025-12-10  8:32:14 0 [ERROR] Can't start server : Bind on unix socket: No such file or directory
2025-12-10  8:32:14 0 [ERROR] Do you already have another server running on socket: /run/mysqld/mysqld.sock ?
2025-12-10  8:32:14 0 [ERROR] Aborting
```

### ISSUE:

```bash
2025-12-10 8:32:14 0 [ERROR] Can't start server : Bind on unix socket: No such file or directory

2025-12-10 8:32:14 0 [ERROR] Do you already have another server running on socket: /run/mysqld/mysqld.sock ?

2025-12-10 8:32:14 0 [ERROR] Aborting
```

- MariaDB is trying to create a **Unix Domain Socket** file `/run/mysqld.sock` isntead of going through TCP network port `3306` because its faster
- It fails because directory doesnt exist, `mysql` **user doesnt have permission** to create it

### REASON:
- in minimal container environment, setup scripts to create that directory are skipped
- `/run/mysqld` is a directory used by MariaDB and MySQL to store its runtime files like:- Unix Domain Socket file, stored in `mysqld.sock`
- `/run` temporary volatile filesystem for system services to store runtime information, usually in memory like `tmpfs`, a reboot clears the memory. Useful for socket files and PIDs for active services.
- `Unix Domain Socket (UDS)` is for `Inter-Process Communication`, its optional to use:
  - its **significantly faster** than `TCP/IP` because it doesnt need to go through the entire network stack *(IP, TCP handshake, port management)*, instead **using kernel internal memory buffer for data transfer**
  - controlled by file system permissions (RW access to `.sock`), not just firewall rules & passwords, a process must have permission to access the file, extra layer of local security
  - **allows the internal MariaDB server process to communicate with any local utility inside the MariaDB container itself (not for another container)**

### FIX:
- need to add a line before `USER/CMD` to manually create the directory

```dockerfile
RUN mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld
```

## 8. optimize image size

### ISSUE:

### REASON:
- The metadata downloaded by apt-get update (the files in /var/lib/apt/lists/) are only needed during the install process ([3/3]). After the install finishes, those lists are dead weight that makes your final image unnecessarily large.
- must treat all temporary files needed for a build as garbage that must be collected in the same layer it was created in.

### FIX:
- Chain Commands: Use the && operator to chain all commands into one RUN instruction.
- Add Cleanup: Immediately follow the install with a cleanup command.
- `update && install && cleanup` applies to almost any container build process (Python's `pip cache purge`, Node's `npm cache clean`, etc.)

- If it runs 50 times, you are saving $16.1\text{ MB} \times 50 = 805\text{ MB}$ of bandwidth and storage transfer, every single day, for every single environment (dev, staging, production).

```bash
IMAGE                 ID             DISK USAGE   CONTENT SIZE
mariadb-test1:latest
                      537403808e0c        602MB          112MB
mariadb-test2:latest
                      ed21d2bbedd1        563MB         95.9MB
```

## 9. check mariadb running
`docker exec -it -u 0 mariadb-server0 mysql`
`SHOW DATABASES;` in MariaDB

</details>

<details>
<summary><h1> CHECKPOINT 1 - MariaDB Init</h1> </summary>
## 1. Hardcode networking config and db init into Dockerfile

```dockerfile
# ARG PENULTIMATE_DEBIAN_STABLE_VERSION
# FROM debian:$PENULTIMATE_DEBIAN_STABLE_VERSION
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld

# 3. [CONCEPT 1] HARDCODE CONFIG CHANGE
# Modify the existing config file to listen on 0.0.0.0
RUN sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mariadb.conf.d/50-server.cnf

# 4. [CONCEPT 2] HARDCODE INIT SCRIPT
# Write the script file line-by-line
RUN echo '#!/bin/bash' > /usr/local/bin/init_db.sh && \
    # Start the service temporarily
    echo 'service mariadb start' >> /usr/local/bin/init_db.sh && \
    echo 'sleep 5' >> /usr/local/bin/init_db.sh && \
    # Run SQL Commands
    echo 'mariadb -e "CREATE DATABASE IF NOT EXISTS test_db;"' >> /usr/local/bin/init_db.sh && \
    echo 'mariadb -e "CREATE USER IF NOT EXISTS giga_user@\"%\" IDENTIFIED BY \"giga_pass\";"' >> /usr/local/bin/init_db.sh && \
    echo 'mariadb -e "GRANT ALL PRIVILEGES ON test_db.* TO giga_user@\"%\";"' >> /usr/local/bin/init_db.sh && \
    echo 'mariadb -e "FLUSH PRIVILEGES;"' >> /usr/local/bin/init_db.sh && \
    # Shutdown temp service
    echo 'mysqladmin -u root shutdown' >> /usr/local/bin/init_db.sh && \
    # Start the real service (PID 1)
    echo 'exec mariadbd' >> /usr/local/bin/init_db.sh && \
    # Make executable
    chmod +x /usr/local/bin/init_db.sh

USER mysql

EXPOSE 3306

# Run the script we just created
ENTRYPOINT ["/usr/local/bin/init_db.sh"]
```

### EXPLANATION
```dockerfile
ENTRYPOINT ["/usr/bin/my-app"]
CMD ["--help"]
```

- Running normally: `docker run my-image` executes `/usr/bin/my-app --help`
- Running with custom args: `docker run my-image start` executes `/usr/bin/my-app start`

- use `ENTRYPOINT` to lock down what the container is (e.g., a web server, a utility script)
- use `CMD` to provide sensible, easily-overridden defaults for how it runs

## 2. Refactor into config files and script

`COPY <source> <destination>`
- `<source>`: file in local host machine. This path must be relative to the directory containing the Dockerfile (the build context).
- `<destination>`: The absolute path inside the image filesystem where you want the file(s) to land.

### Dockerfile
```dockerfile
FROM debian:bookworm-slim

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
```

### Config ("srcs/requirements/mariadb/conf/50-server.cnf")
```conf
[mysqld]
user = mysql
pid-file = /run/mysqld/mysqld.pid
socket = /run/mysqld/mysqld.sock
port = 3306
basedir = /usr
datadir = /var/lib/mysql
tmpdir = /tmp
lc-messages-dir = /usr/share/mysql

# The Clean Fix: Listen to everyone
bind-address = 0.0.0.0

query_cache_size = 16M
log_error = /var/log/mysql/error.log
```

### Init Script ("srcs/requirements/mariadb/tools/init_db.sh")
```sh
#!/bin/bash

# 1. Start the service (The "Hack" way)
service mariadb start
sleep 5

# 2. Check if the database variables are actually set (Safety Check)
if [ -z "$MYSQL_DATABASE" ]; then
    echo "Error: MYSQL_DATABASE is not set!"
    exit 1
fi

# 3. The SQL Injection (Now using variables!)
mariadb -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mariadb -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mariadb -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
mariadb -e "FLUSH PRIVILEGES;"

# 4. Shutdown and Restart
mysqladmin -u root shutdown
exec mariadbd
```

## 3. Make docker compose for mariadb only

### Prepare .env example
```yaml
# Domain
DOMAIN_NAME=login.42.fr

# MySQL Setup
MYSQL_DATABASE=db
MYSQL_USER=user
MYSQL_PASSWORD=password
MYSQL_ROOT_PASSWORD=password

# We will use this later for WordPress
WP_ADMIN_USER=user
WP_ADMIN_PASS=password
```

### docker-compose.yml
```yml
version: "3.8"

services:
  mariadb:
    # 1. Build from your directory
    build:
      context: ./requirements/mariadb
      dockerfile: Dockerfile
      # If you used ARG in Dockerfile, define it here:
      # args:
      #   - PENULTIMATE_DEBIAN_STABLE_VERSION=bullseye

    # 2. Container Name (easier to type than the random ID)
    container_name: mariadb

    # 3. Inject Environment Variables from .env automatically
    environment:
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

    # 4. Persistence (So you don't lose data on restart)
    volumes:
      - mariadb_data:/var/lib/mysql

    # 5. Networking (Private network for Inception)
    networks:
      - inception

    # 6. Stability
    restart: always

# Define the shared resources
volumes:
  mariadb_data:
    driver: local
    # opts:
    #   type: none
    #   o: bind
    #   device: /home/login/data/mariadb # ⚠️ Update 'login' to your user!

networks:
  inception:
    driver: bridge
```

- Launch: `docker compose -f srcs/docker-compose.yml up --build -d`
- Verify: `docker compose -f srcs/docker-compose.yml ps`
- Connect: `docker exec -it mariadb mariadb -u <USERNAME> -<PASSWORD>`

- `-f srcs/docker-compose.yml` finds the configuration file *(optional: docker compose up alone will do, will default to the docker-compose.yml file)*
- `up` starts the services
- `--build` force rebuild
- `-d` detached

## 4. Ensure MariaDB is PID 1 in container

### ISSUE:
- The `init_db.sh` runs mariadb as the background process, then `exec mariadb`, it replaces the bash process as PID 1, but mariadb was already running in the background, so `docker stop` signals go to the foreground mariadb but forgot the background one.

### REASON:
- `sleep 5` is a hack currently, but if mariadb takes 5.1 seconds to boot, creating a race condition, everything will fail.

### FIX:
- **Socket Polling** - looping until a connection is heard
- **Idempotency** - applying it multiple times has the same effect as applying it just once, in this context:
	- First Run: container is fresh, create databases and users
	- Restart: DB exists, skip initialization to avoid overwriting data

### UPDATED init_db.sh
```bash
#!/bin/bash
set -e # Exit instantly if any command failed

# 1. Idempotency check
if [ -d "/var/lib/mysql/mysql" ]; then
	echo "Database already initialized. Starting server..."
	exec mariadbd --user=${MYSQL_USER} --bind-address=0.0.0.0
fi

echo "Initializing Database"

# 2. Start temporary server
# & puts mariadb in background, $! gets the most recently executed process ID
mariadbd --user={MYSQL_USER} --datadir=/var/lib/mysql --skip-networking & PID="$!"

# 3. Polling
# Wait for DB to connect
echo "Waiting for MariaDB to be ready..."
until mysqladmin ping -h localhost --silent; do
	sleep 1
done

# 4. Check if the database variables are actually set (Safety Check)
if [ -z "$MYSQL_DATABASE" ]; then
    echo "Error: MYSQL_DATABASE is not set!"
    exit 1
fi

# 5. The SQL Injection (Now using variables!)
mariadb -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mariadb -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mariadb -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
mariadb -e "FLUSH PRIVILEGES;"

# 6. CLeanly shutdown temporary server
echo "Shutting down temporary server"
mysqladmin -u root shudown
wait "$PID" # script will not execute next if previous PID was not shutdown properly

# 7. Start MariaDB as PID 1
echo "Replacing MariaDB as PID 1"
exec mariadbd --user=${MYSQL_USER} --bind-address=0.0.0.0
```

## 5. Created Makefile to initialize volume (considered bind mount because its a custom directory, not managed by docker engine)

```Makefile
NAME				=	inception
DOCKER_COMPOSE_FILE	=	./srcs/docker-compose.yml
DATA_PATH			=	/home/cwoon/data

GREEN		= \033[0;32m
RESET		= \033[0m

# .SILENT:

all : up

setup:
	mkdir -p $(DATA_PATH)/mariadb
	echo "$(GREEN) Data volumes created at $(DATA_PATH)$(RESET)"

up : setup
	echo "$(GREEN)Building and starting Inception...$(RESET)"
	docker compose -f $(DOCKER_COMPOSE_FILE) up --build -d

down:
	echo "$(GREEN)Stopping inception...$(RESET)"
	docker compose -f $(DOCKER_COMPOSE_FILE) down

# Clean everything (Containers, Networks, Images, Volumes)
clean: down
	docker system prune -af

fclean: clean
	sudo rm -rf $(DATA_PATH)
	docker volume prune -f

re: fclean all

.PHONY: all setup up down clean fclean re
```
</details>

<!-- ### ISSUE:
### REASON:
### FIX: -->
