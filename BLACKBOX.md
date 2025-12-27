1. wtf are the flags?
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=MY/ST=Selangor/L=SubangJaya/O=42/OU=42/CN=cwoon.42.fr"
```

2. whats --no-cache flag?
```Dockerfile
RUN apk update && apk add --no-cache nginx openssl
```

3. not sure what ssl refers to, whats the context
```conf
server {
	listen 443 ssl;
	listen [::]:443 ssl;
}
```
