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

1. whats --no-cache flag?
```Dockerfile
RUN apk update && apk add --no-cache nginx openssl
```
- Normally when a package is installed, the package manaer downloads an index of available software (cache) and stores it to disk, allowing for faster lookups later
- with `--no-cache`, the index is downloaded to RAM instead, then package is installed, and the index is immediately deleted, it is also equivalent to doing `apk update`
- so final command can be simplified to `RUN apk add --no-cache nginx openssl`, it will always install latest versions of the packages unless specific version is specified

1. not sure what ssl refers to, whats the context
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
5. How to break my infrastructure, get a 502 Bad Gateway Error from NGINX
6. What is the clear distinction between the MariaDB users and the Wordpress users
7. How much further can I optimize my docker-compose to be more configurable, less repeating vars, more solid IaC, seems like you can actually pass the configs in from the docker compose, so youll never really have to touch the dockerfiles
8. Need to use secrets instead of env
9. How to prove that nginx is sharing the volume with wordpress
10. How to prove that all processes are running on PID 1, maybe can purposely try a tail -f command to make it loop and make things corrupted when you close it
11. Justify the use of self-signed certificates instead of using CA ones
12. Learn how to display the default nginx page with http://localhost:80
13. Must the ssl cert be created in the nginx container, after creation can the package be deleted to keep it small, or is it overengineering, how to verify its creation, inside the container or outside
14. Difference between Makefile and Docker Compose, whats the purpose of makefile, is it an industry standard
