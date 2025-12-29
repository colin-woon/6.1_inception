ARG PENULTIMATE_ALPINE_STABLE_VERSION="3.22"
FROM alpine:$PENULTIMATE_ALPINE_STABLE_VERSION

RUN apk add --no-cache nginx openssl

ARG DOMAIN_NAME="<login>.42.my"
RUN mkdir -p /etc/nginx/ssl && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=MY/ST=KL/L=KL/O=42/OU=Inception/CN=${DOMAIN_NAME}"

COPY conf/custom-nginx.conf /etc/nginx/http.d/z-custom-nginx.conf

RUN mkdir -p /var/www/html

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

# FOR DEBUGGING
# apk info -L nginx (equal to dpkg -L nginx)


# apk update
# apk add nginx openssl curl
# sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
# -keyout /etc/ssl/private/nginx-selfsigned.key \
# -out /etc/ssl/certs/nginx-selfsigned.crt \
# -subj "/C=US/ST=State/L=City/O=Dev/OU=Edge/CN=YOUR_IP_OR_DOMAIN"
