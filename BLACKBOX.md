1. wtf are the flags?
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=MY/ST=Selangor/L=SubangJaya/O=42/OU=42/CN=cwoon.42.my"
```
a. `-keyout` saves private key location
b. `-out` saves public cert location
c. `-subj` prefill cert info to skip prompts
d. `req` use the Certificate Signing Request (CSR) Tool, a digital application form that you fill in with `-subj`, usually its sent to a CA like DigiCert or Let's Encrypt
e. `-x509` "no Data Encryption Standard (DES) (AES is the successor)" skip the sending to CA step, sign in yourself, its the international standard format for public key certs
f. `-nodes` keeps the private key unencrypted so the docker container Nginx can read it automatically, otherwise human intervention needed to key in password if its encrypted
g. `rsa:2048` - `rsa` is most compatible where almost all devices in last 30 years understands it, `2048` bit is the industry standard, `1024` is considered breakable by powerful computers, `4096` is very secure but much slower for server to process,
`ECDSA (Elliptic Curve)` is another option to RSA, much smaller and faster, 256 is as strong as 3072 rsa, but its not supported by legacy browsers and hardware

```sh
C: Country (MY for Malaysia)
ST: State (Selangor)
L: Locality (Subang Jaya)
O/OU: Organization / Unit (42)
CN: Common Name (Your domain/login)
```

2. whats --no-cache flag?
```Dockerfile
RUN apk update && apk add --no-cache nginx openssl
```
- Normally when a package is installed, the package manaer downloads an index of available software (cache) and stores it to disk, allowing for faster lookups later
- with `--no-cache`, the index is downloaded to RAM instead, then package is installed, and the index is immediately deleted, it is also equivalent to doing `apk update`
- so final command can be simplified to `RUN apk add --no-cache nginx openssl`, it will always install latest versions of the packages unless specific version is specified

3. not sure what ssl refers to, whats the context
```conf
server {
	listen 443 ssl;
	listen [::]:443 ssl;
}
listen [address]:port [parameters];
parameters options:
	- ssl
	- http2 (older nginx, newer one is "http2 on")
	- default_server
	- proxy_protocol
	- reuseport

listen [::]:443 ssl - IPv6 configuration, :: is like 0.0.0.0 for IPv4, because : is used as a syntax delimeter <address>:<port>, [] is needed to differentiate colons in IPv6 addresses (eg: fe80::1)
```

4. What are the manual steps/commands to create Wordpress users
```bash
docker exec -it \<wordpress_container\> bash
wp user create test test@mail.com --role=author --user_pass=pass --allow-root
```
- `--allow-root` is important as the safety mechanism for WP-CLI is to not allow root to run commands as it can mess up file permissions or allowed compromised plugin to gain full access to system
- `www-data` is usually the owner of wordpress files in `/var/www/html`, can check with `ls -la` in that directory to see.

5. Why is wordpress installation seperated from `Dockerfile` into `setup.sh`
- `wp-cli` is the tool that installs wordpress, through `wp core download`
- If wp was installed during the Dockerfile build phase, after it populates `/var/www/html` and the container launches, docker will mount the host machine volume that is connected to it (usually an empty file), and **overwrite** whats in the container, making all your wordpress files and configs disappear
- `wp core install` needs to initialize wordpress default databases, if ran during the build phase, mariadb probably hasnt even launched yet, leading to database connection error

6. How to break my infrastructure, get a 502 Bad Gateway Error from NGINX


7. What is the clear distinction between the MariaDB users and the Wordpress users
- mariaDB (database layer) users are those who can access the database, wp_user is one of them, its representing the entire wordpress application itself
- wordpress (application-level) users are the actual business logic people, like admin, author, subscriber on the wordpress website, it can be any website, they themselves are the data stored inside mariaDB wp_users

8. How much further can I optimize my docker-compose to be more configurable, less repeating vars, more solid IaC, seems like you can actually pass the configs in from the docker compose, so youll never really have to touch the dockerfiles
- use `env_file:` in docker compose and pass in the entire .env

9. Need to use secrets instead of env
- if only .env is used, with `docker inspect <container_id>` you can see all env variables passed inside, including passwords

10.  How to prove that nginx is sharing the volume with wordpress
- Enter the WordPress container: docker exec -it wordpress-test sh
- Create a file in the shared directory: touch /var/www/html/proof.txt
- Exit and enter the NGINX container: docker exec -it nginx-test sh
- Check if it's there: ls /var/www/html/
- ALSO: another way is to do docker inspect and see the mounts, will see the same `Source:`

11.    How to prove that all processes are running on PID 1, maybe can purposely try a tail -f command to make it loop and make things corrupted when you close it
- `docker exec <container> ps aux`
- try it with this `CMD nginx && tail -f /dev/null`
- then `time docker stop nginx-test`
- it will take exactly 10 seconds, Docker first sends `SIGTERM` to tail (PID 1), after 10 seconds, since nginx is still runnning as a seperate process, Docker sends `SIGKILL`, basically doing a hard crash and potentially corrupting data

12.   Justify the use of self-signed certificates instead of using CA ones
- CAs only issue certificates for domain names in **Global Public DNS**, current setup is more of a simulation of a DNS, as domain names need to be paid
- Infrastructure Autonomy - in professional system administration, internal services should not depend on any external APIs for basic security. By generating a self-signed certificate, infrastructure can work offline without external dependencies, CAs require active internet connection and a callback from their servers to yours
- Self-signed certificates use the same AES encryption as a $1000 certificate from CA, the primary difference is just the Identity Verification, for an internal project where I am both the server owner and the user, i already trust the identity

13.  Learn how to display the default nginx page with http://localhost:80


14. **Must the ssl cert be created in the nginx container, after creation can the package be deleted to keep it small, or is it overengineering, how to verify its creation, inside the container or outside**
- Option A, SSL in the Dockerfile, pros: container boots faster, cons: if domain name needs to change, image needs to be rebuild
- Option B, SSL in the setup script, pros: highly configurable, easy to use .env variables to set domain name, cons: add a few seconds to container start
- Option B is better for IaC, allows to change domain name whenever without rebuilding entire NGINX image
- Dont have to delete openssl as in alpine its very small, although its common to do so for build tools in dockerfile
- Verification steps:
  - docker exec -it nginx-test ls -l /etc/nginx/ssl/
  - docker exec -it nginx-test openssl x509 -in /etc/nginx/ssl/inception.crt -text -noout (inside container)
OR
  - echo | openssl s_client -connect localhost:443 -servername cwoon.42.fr 2>/dev/null | openssl x509 -noout -subject -dates (outside container)

15.   **Difference between Makefile and Docker Compose, whats the purpose of makefile, is it an industry standard**
- Apparently yes, Makefile sets up the host environment, while Docker compose orchestrates the containers, bash scripts handle more complex logic, and Makefile and bash scripts are used together for automation

16. **There was a lot of warnings from AI that either my Dockerfile or my scripts was running as root and its considered dangaroues, need to find out which files is it referring to and why**
- Principle of Least Privilege, all final execution should not run as root, if the container is compromised, root access allows all stuffs, so the PID 1 processes should ideally be in the lowest privelege


17. How to manually do port forwarding to access the wordpress website from my VM to my Host windows
- make sure /etc/hosts in windows and linux have set `127.0.0.1 cwoon.42.my`
- Set NAT in VM settings, make sure Host and Guest ports are configured for 443, industry standard as browser assumes https:// uses port 443
- if want to be visible to everyone on the network, leave Host IP empty, as it will default to 0.0.0.0, then just go to another device, and enter the host machine (your own computer's) IP address for the connected WiFi Network, will be able to see the site


18. Why specifically port 443, how is it different from port 80
- 80 is Hypertext Transfer Protocol, old school
- 443 is Hypertext Transfer Protocol Secure, its HTTP wrapped inside an encrypted layer called TLS
  - it will always try to perform the SSL/TLS handshake first between the client(browser) and the server

19.  In wordpress container i made the php version as a variable, should i do the same for mariadb and nginx
- yes, its for flexibility and maintainability, avoids modifying the dockerfile source

20. is `/etc/hosts` considered cheating for setting up domain name?
- no, its standard for local development, it acts as a DNS, otherwise 42.fr would redirect to the official website

21. Wordpress vs Nginx
In a LEMP stack:
- NGINX handles the static files (images, .css, .js). It reads them directly from the disk.
- PHP-FPM (WordPress) handles the dynamic files (.php). It reads the code from the disk, executes it, and sends the result back to NGINX.

22. why is pid 1 so important
- if the service crashes as another PID in the container, docker will not detect it, and hence it wont restart itself even if you specified to `restart: always`


23. for wordpress PID 1, why is it root user instead of www-data
- the PHP-FPM needs root to bind to port 9000 and switch users, its workers should correctly switch to www-data user


BONUS
24. find out why commenting out the proxy_set_headers still works, whats the difference
25. how to break redis
26. how to know redis is working, actually using its functionality?
27. how does the ftp work?
28. can i only prove the ftp works with terminal commands, no ui?
29. what are the ftp ports, never seen those numbers before
30. what are the uids and how are they relevant
31. find out how does the cgroups work for manual cadvisor installation, there were lots of volumes
32. to explore multi-stage building in dockerfiles
33. check and see some of the bonus volumes should be a bind mount managed by docker or not
34. uptime kuma needs a while to only work


MANDATORY TODO
- visualize infra
- add on bonuses documentation in README
- make every user follow principle of least privilege

- prepare a list of what, why, and how to verify something is working for the evals

DOCKERFILE
- **ADD vs COPY** (ADD can do remote url downloads like curl and also unzip files, but its not flexible, so COPY is more straightforward)
- **CMD vs ENTRYPOINT** (CMD can be overridden, more like arguments passed in, ENTRYPOINT makes the container like an executable, always runs it, CMD is more for backup)
- **USER** (sets the UID for the container instance, For maximum security, a specific UID different for each different services, different from the host machine, so if host machine is compromised, cant access files in other containers, MAINLY CONCERNED WITH VOLUMES OR MOUNTS ONLY)
- **EXPOSE** (more for documentation on what port it is using)
- **how docker cache builds work** (from least changed to most changes top to bottom, any changes triggers a rebuild from that moment onwards)
- **Copy-on-Write** (1 image = 500mb, 1 container = 3mb extra, the rest read from image, 10 containers? = just 30mb instead of 5000mb)
- **APT vs APT-GET** (apt is a wrapper for apt-get, apt-cache etc. its not really stable for scripting, apt-get is the industry standard for docker container scripts)

IDEMPOTENCY
- explain what it is, refer to mariadb script is pretty good, show the remote root example with adminer

NETWORK
- **Docker VPN:** `docker network inspect inception`

VOLUMES
- **Wrapped and Managed by Docker:** should be able to see them with `docker volume ls`

PID 1
- Check PIDs in container: `docker exec <container> ps aux`
- `tail -f` experiment: check nginx Dockerfile

MARIADB
- **Shows network connection:** try to ping from wordpress using `docker exec -it wordpress mysqladmin -h mariadb -u $MYSQL_USER -p$MYSQL_PASSWORD ping`
- **Show persistence:** update wordpress page theme, then `make down` and `make` again
- **Show mounts:** `docker inspect mariadb | grep -A 10 Mounts`
- config (quite straight forward, located in `/etc/mysql`)
- init script ()
- what daemon used (mariadbd, comes from the mariadb-server package from apt repository, mysqladmin = utility tool, mariadb = client CLI, mariadbd = db server engine)

WORDPRESS
- Sign in as Wordpress user and try to comment (`/wp-login`)
- Sign in as Administrator in WP to access dashboard, then edit a page, and verify it was updated (`/wp-admin`)
- Rename the `index.php` file, should get `403` or `404` error from nginx
- explain FastCGI:
  - *"NGINX is a web server, but it doesn't speak PHP. With NGINX as a Reverse Proxy, when a .php request comes in, NGINX wraps it in the FastCGI protocol and sends it to the WordPress container on port 9000. PHP-FPM (FastCGI Process Manager) then executes the code and sends the HTML back."*
- config (located in `/etc/php/${PHP_VERSION}/fpm/pool.d/z-custom-www.conf`)
- init script (download source code for wordpress, configure link to mariadb, init databases with an admin account and with wordpress stuff, create normal user and give access permissions)
- what daemon or CLI used (its daemon is mainly php-fpm, wordpress is just a bunch of .php files and php-fpm executes them)

NGINX
- proxy means to handle for you, forward proxy is like a vpn, protects the client, while reverse proxy protects the server, intercepts incoming requests before they reach the server.
- **Why are self signed certs needed:** to ensure environmental parity (dev, staging, prod are all same, able to test secure features)
- **Why strictly TLS 1.2v and above:** BEAST, POODLE, Sweet32 attacks happened
- **Who handles TLS encryption:** Nginx does it at the application layer, browser must agree with it, so it protects the server, the SSL cert is just an identifier
- **Why inject the ssl cert and key instead of creating it in nginx dockerfile:** private key is permanently stored in image history, seperation of concerns (person who handle certs is different from person who maintains nginx dockerfile, made nginx stateless)
- **Verify Encryption of HTTP vs HTTPS**:
    - `sudo tcpdump -i any port 80 -A` , `curl http://cwoon.42.my`
    - `sudo tcpdump -i any port 443 -X` , `curl -k https://cwoon.42.my`
- **Verify SSL cert:** `openssl s_client -connect localhost:443 -tls1_3`
- **Why NGINX shares volumes with Wordpress**
  - *"Both NGINX and WordPress share the /var/www/html volume. This is critical because NGINX needs to serve static assets (CSS/Images) directly from the disk for speed, while the WordPress container needs the same files to execute the PHP logic. Without the shared volume, you'd get a functional site with no styling (broken CSS)."*
- **Why is PID 1 master process running as root:** Ports under 1024 in Linux need `root` privileges to claim, helps to spawn the worker processes, and /run/secrets/ssl_key (private) should only be accessed by root
- config (located in `/etc/nginx/http.d/z-custom-nginx.conf`)
- what daemon or CLI used (`nginx -g daemon off` - `-g` injects the `daemon off` config that isnt in `nginx.conf`, tells nginx to not close the original process after spawning workers or else docker will think PID 1 is done and shut everything down, )

STATIC WEB PAGE
- took the `dist/` folder generated by `npm build`, that folder represents all the raw html/css/js that can be rendered by any browser

ADMINER
- installation
  - db drivers: `mysqli & pdo_mysql`
  - runtime installation: `curl -L -o index.php`, ensures latest version of adminer everytime, renaming it to `index.php` allows php built-in webserver to execute it
  - stateful: `session` package helps admienr to remember logins
- config (since port 8080 is not below 1024, a regular user will do, so i created an adminer user)
- daemon - uses php built-in webserver `php82 -S 0.0.0.0:8080`
- importance (acts as an administration proxy, has gui, allows emergency access to db if wp site is down, allows resource optimization auditing, and extremely portable compared to phpMyAdmin, single file whereas phpMyAdmin has thousands of files)

REDIS (Remote Dictionary Server)
- installation (`redis-server`, very straightforward to setup the container)
- config (listen to `0.0.0.0` and turn `off protected mode` to allow external connections)
- config with wp script (install and activate the redis plugin on wp, inject hostname and port config used (`redis 6379`), enables redis using `object-cache.php` in the `wp-contents/` folder)
- importance - helps with speed, cost by allowing scaling for cache layer to handle traffic spikes, much cheaper than scaling relational db, also helps wiht session management so user isnt logged out when website crashed, specific data structure can optimize performance more depending on the scenario
- Object Cache - temporary storage area that keeps frequently accessed data in RAM, data stored in key-value pairs, value can be any data structure
- daemon - `redis-server`
- **Refresh WP website while running this:** `docker exec -it redis redis-cli monitor`, will see bunch of `GET` and `SET`
- **If redis crashes, will website crash?** No it will just fallback to mariadb container (but the fallback needs to be setup somewhere)

FTP
- installation
- config
- importance?

CADVISOR
- importance (to monitor resource usage for each container, spotting any performance bottlenecks)
- installation (curl the binary from Google's official github repo)
- config (need to map volumes in docker compose for the linux cgroups, port by default is 8080)
  - `privileged: true` - allows container to access kernel level information for hardware stats, runs as `root`
  - `device: /dev/kmsg` - kernel log buffer, detect when containers are created or destroyed, catch out of memory kills

| Host Path         | Destination       | Why?                                                                         |
| ----------------- | ----------------- | ---------------------------------------------------------------------------- |
| `/`               | `/rootfs`         | To see the overall disk usage of your VM.                                    |
| `/var/run`        | `/var/run`        | Specifically to find `docker.sock` so it can talk to the Docker Engine.      |
| `/sys`            | `/sys`            | **The most important.** This is where the `cgroups` live (CPU/RAM/IO stats). |
| `/var/lib/docker` | `/var/lib/docker` | To see how much disk space each specific container's layers are taking.      |
| `/dev/disk`       | `/dev/disk`       | To monitor physical disk health and throughput.                              |
Everything should be read-only (`:ro`)


UPTIME KUMA
- installation (done using dockerfile multistage build mainly to reduce final image size, also utilizing bun for faster installs)
  - `eatmydata` - skips syncing data with disk, makes `apt-get` installation faster
  - `bun install --production` - only production related dependencies, no documentation or tests
  - `bun run download-dist` - downloads the UI (html/css/js)
- config
  - `sqlite` - used to be a single file called `kuma.db`
  - `mariadb` - integration with mariadb allows for higher performance
  - the volume is needed for metadata like session keys, icons
- importance (operational awareness, knowing whether its healthy AND alive)
