# Services Provided
- **Web Server**: NGINX providing HTTPS access via TLSv1.2/v1.3.
- **Content Management**: WordPress powered by PHP-FPM.
- **Database**: MariaDB for secure data storage.

**BONUS**
- **Object Cache Memory**: Redis caches frequently accessed WordPress queries in RAM
- **Resource Monitoring**: cAdvisor (Container Advisor) provides real-time analysis of resource usage across all running containers
- **Infrastructure Monitoring**: Uptime Kuma tracks service availbility
- **Database Administration GUI**: Adminer, a single PHP file for interacting with MariaDB tables
- **File Transfer Protocol**: vsftpd (Very Secure FTP Daemon) allows secure remote file management of WordPress root directory, seperated from network traffic.
- **Static Portfolio Web Page**: Shows NGINX routing capabilities

# Operational Guide
- `make` - Starts all services
- `make down` - Stops all services without deleting the data
- `make fclean` - Stops all services and deletes the data

# Website Access (Ensure login and country matches your .env)
- **User Site**: https://cwoon.42.my
- **Admin Site**: https://cwoon.42.my/wp-admin
- **cAdvisor Site**: https://cwoon.42.my/cadvisor
- **Uptime Kuma Site**: https://cwoon.42.my/uptime
- **Adminer Site**: https://cwoon.42.my/adminer
- **Portfolio Site**: https://portfolio.cwoon.42.my

# Credentials & Health Checks
- All credentials are located in the `/secrets` directory of the project
- Use `docker ps` in the terminal to check all containers are up, or navigate to the **Uptime Kuma** site to see health statuses