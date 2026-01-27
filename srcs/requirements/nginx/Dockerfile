ARG PENULTIMATE_ALPINE_STABLE_VERSION="3.22"
FROM alpine:$PENULTIMATE_ALPINE_STABLE_VERSION

ARG NGINX_VERSION="1.28.0-r3"
RUN apk add --no-cache nginx=${NGINX_VERSION} openssl

ARG DOMAIN_NAME="<login>.42.my"
RUN mkdir -p /etc/nginx/ssl && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=MY/ST=KL/L=KL/O=42/OU=Inception/CN=${DOMAIN_NAME}"

# For testing port 80 http, remember to change the docker compose 80:80
# COPY conf/custom-nginx-80.conf /etc/nginx/http.d/z-custom-nginx.conf
COPY conf/custom-nginx.conf /etc/nginx/http.d/z-custom-nginx.conf

RUN mkdir -p /var/www/html

# This makes 'docker logs' actually work, treats logs as streams instead of files, following Twelve-Factor App methodology
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 443
# EXPOSE 80

# # For testing tail -f, use time docker stop nginx-test and it should take at least 10 seconds
# CMD nginx && tail -f /dev/null
CMD ["nginx", "-g", "daemon off;"]
