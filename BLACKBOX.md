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