# 1. Environemnt Setup (Prerequisites)
- **Hardware**: VM with 8GB RAM, 4 Cores recommended (Minimum 4GB RAM, 2 Cores).
- **System**: Ubuntu Server with Docker Engine installed.
- **Local DNS**: You must map your domain in the host's `/etc/hosts` file: `127.0.0.1 cwoon.42.my`. If your host is on Windows, run **Notepad as administrator** and add `127.0.0.1 cwoon.42.my` to `C:\Windows\System32\drivers\etc\hosts`
- **Windows-to-VM NAT**: Using Oracle VirtualBox, go to *Settings > Network > Port Forwarding* and map port `443` so you can connect to the website from your windows browser. **As for development, setting up SSH is very useful.**
- **Secrets**: Create the following secrets in the `/secrets` folder:
  - `db_credentials.txt`
  - `db_password.txt`
  - `db_root_password.txt`
  - `ftp_password.txt`
  - `wp_admin_credentials.txt`
  - `wp_admin_password.txt`
  - `wp_user_credentials.txt`
  - `wp_user_password.txt`
- **Nginx Config**: Edit the server blocks to match your desired routes in `/srcs/requirements/nginx/conf/custom-nginx.conf`

# 2. Build & Launch
**NOTE: Change `$DATA_PATH` to match your VM directory structure.**
- `make` Builds the docker images and starts all containers
- `make clean` Clean everything (Containers, Networks, Images)
- `make fclean` Hard resets the environment, even deletes the volume bind mounts in `$DATA_PATH`

# 3. Data Persistence & Management
**Docker CLI Manual** - `docker --help`

**Storage Location**
- Stored in `$DATA_PATH`, typically `/home/<login>/data`

**Container Management**
- Container status: `docker ps`
- Access container log: `docker logs <container>`
- Streams container log: `docker logs -f <container>`
- Inspect container details: `docker inspect <container>`
- Access container: `docker exec -it <container> bash` OR `docker exec -it <container> sh`
- Check PIDs in container: `docker exec <container> ps aux`
- Check container PID in host: `docker top <container>`
- Run temporary container: `docker run --rm -it debian:bookworm-slim bash` OR `docker run --rm -it alpine:3.22 sh`

**Volume Management**
- List all docker managed volumes: `docker volume ls`
- Inspect volume details: `docker volume inspect <volume-name>`

**Network Management**
- Inspect network details: `docker network inspect <network_name>`

**Image Management**
- List images: `docker images`