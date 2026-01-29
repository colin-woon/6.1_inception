*This project has been created as part of the 42 curriculum by cwoon*

# Description
This project is a System Administration exercise designed to broaden the knowledge on virtualization using Docker. The goal is to setup a small and secure infrastructure of services (NGINX, MariaDB, Wordpress) running in dedicated containers. The services must be built from scratch using custom Dockerfiles to ensure a deep understanding of container orchestration, networking, and volume management.

# Instructions
## 1. Prerequisites (based on how this project was created)
- A VM configured with 8gb ram, 4 cores (min 4gb, 2 cores)
- Ubuntu Server ISO
- Docker Engine
- Setup your `.env` following the `.env.example`, `DOMAIN_NAME` format = `<YOUR_LOGIN>.42.<COUNTRY>`
- Host Configuration: Add `127.0.0.1` `https://$DOMAIN_NAME` to your `/etc/hosts` file.
- Create the following `secrets`:
  - `db_credentials.txt`
  - `db_password.txt`
  - `db_root_password.txt`
  - `ftp_password.txt`
  - `wp_admin_credentials.txt`
  - `wp_admin_password.txt`
  - `wp_user_credentials.txt`
  - `wp_user_password.txt`

## 2. Compilation and Execution
This infrastructure is managed by a `Makefile` at the root of the project
**NOTE: Change `$DATA_PATH` to match your VM directory structure.**
- `make` Builds the docker images and starts all containers
- `make clean` Clean everything (Containers, Networks, Images)
- `make fclean` Hard resets the environment, even deletes the volume bind mounts in `$DATA_PATH`

## 3. Requirements Verification
- **Access**: Navigate to `https://$DOMAIN_NAME` in your browser.
- **SSL Check**: Run `curl -kv https://$DOMAIN_NAME` to check for TLSv1.2/TLSv1.3 handshake
- **PID 1 Processes**: Use `docker exec <container> ps aux` to ensure services are running on PID 1. Using `docker top <container>` showing only 1 process is also a good indicator, but `ps aux` is more reliable.

# Resources
## Links
- **Docker Engine setup on Ubuntu Server**: https://docs.docker.com/engine/install/ubuntu/
- **Docker Compose**: https://docs.docker.com/compose/
- **Debian Slim Image**: https://hub.docker.com/_/debian
- **Alpine Linux Image**: https://hub.docker.com/_/alpine
- **MariaDB Image Repo**: https://github.com/MariaDB/mariadb-docker
- **Wordpress Image Repo**: https://github.com/docker-library/wordpress
- **NGINX Image Repo**: https://github.com/nginx/docker-nginx

**BONUSES**
- **Uptime-Kuma Repo**: https://github.com/louislam/uptime-kuma
- **cAdvisor Repo**: https://github.com/google/cadvisor
- **Redis Image Repo**: https://github.com/redis/docker-library-redis
- **FTP Docker Hub**: https://hub.docker.com/r/fauria/vsftpd
- **FTP Alpine Linux**: https://wiki.alpinelinux.org/wiki/FTP
- **Adminer Image Repo**: https://github.com/TimWolla/docker-adminer

## AI Usage
- Using those links as reference helped AI to generate more accurate, up-to-date and secure Dockerfiles
- Debugging network issues
- Setup initialization scripts
- Understanding of service components
- Assist in infrastructure decisions for best practices
- Identify security vulnerabilities

# Project Description
## Design Choices
- **Penultimate Stable Versions as of 10/12/2025:**
  - **Debian Slim** - Bookworm (v12), latest is Trixie (13) `glibc`
    - **For services that require stability and have complex runtimes:**
      - **Databases: MariaDB, Redis** (requires filesystem predictability)
      - **Wordpress** (pre-compiled binaries and extensions are tested against `glibc`)
      - **cAdvisor** (a complicated go binary, requires consistent `glibc` headers)
      - **Uptime Kuma** - (utilizes Node.js, native modules precompiled for `glibc` + DNS stability)
  - **Alpine** - (3.22), latest is (3.23) `musl libc`
    - **For services that are lightweight:**
      - **NGINX** (minimal attack surface since its a public endpoint, easy to scale and startup)
      - **FTP** (no complex dependencies on C++ libraries, single responsibility service)
      - **Adminer** (easy to "Run and Kill", its just a single PHP file)

- **Infrastructure as Code (IaC):** All configurations (PHP versions, Domain names) are passed through an `.env` file to the `docker-compose.yml` for maximum maintainability, avoiding hardcoded values

- **Security**: NGINX is the sole entry point (Port 443), utilizing self-signed certificates to simulate a production environment without external DNS dependencies.

## Virtual Machines vs Docker
| Feature | Virtual Machine          | Docker (Containers) |
| ------- | ------------------------ | ------------------- |
| **OS**  | Includes a full Guest OS | Shares the Host OS kernel |
| **Size** | Gigabytes (includes kernel/drivers) | Megabytes (e.g., Alpine is ~5MB) |
| **Boot Time** | Minutes | Seconds |
| **Isolation** | Hardware-level virtualization | Process-level isolation

## Secrets vs Environment Variables
- **Environment Variables:** `.env` is easy to use but visible via `docker inspect <container>`. Used for non-sensitive data like `DOMAIN_NAME`.
- **Secrets:** Stored in files (e.g., db_password.txt) and ignored by Git.

## Docker Network vs Host Network
- **Docker Network**: Creates an isolated bridge where containers communicate via service names (e.g., `wordpress:9000`). This is mandatory for this project.
- **Host Network**: Bypasses isolation and uses the host's IP directly. This is strictly **forbidden** as it breaks the containerization principle.

## Docker Volumes vs Bind Mounts
- **Docker Volumes**: Managed by Docker in a specific part of the host file system. Preferred for database persistence.
- **Bind Mounts**: Maps a specific host path (e.g., `/home/cwoon/data`) to a container path. Used here to ensure data persists even if containers are deleted and recreated.
