### How to check PID 1
- `docker top <container>` shows host machine PID and the container process PID respective to the host, so not a good way to check if the container is PID 1 in its own environment
- `docker exec -it <container> ps aux`, this will show the PID

### Difference between --user=mysql vs --user=${MYSQL_USER}
-

### For Volume custom directories that require root access, thats where the Makefile is useful


### Database credentials should be stored in secrets folder because `docker inspect <container>` will reveal all .env stuff


### 0.0.0.0 vs 127.0.0.1
- By using `0.0.0.0`, MariaDB listens on the **Virtual Network Interface** that Docker created, allowing other services in the network to talk to it, but not the host IP, making it secure and safe

### --skip-networking & and ping
- when initializing the DB (setting passwords/creating users), the database is vulnerable if its open to the public network.
- `&` allows the DB to run in background so the script can continue, and `ping` waits for the DB to fully load because if you tried to run `CREATE DATABASE` right after starting the server it would fail

### if host volume is deleted, will it affect the container volume that is binded to it
- yes, since theyre in sync

### % is a wildcard in SQL
- `'user'@'localhost'` -- user can only connect from the same container
- `'user'@'192.168.1.5'` -- user can only connect from that specific IP
- `'user'@'%'` -- user can only connect from **ANY** specific IP
- we use `%` because everytime containers are restarted, different internal IP is assigned to the container
