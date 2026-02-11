ARG PENULTIMATE_ALPINE_STABLE_VERSION="3.22"
FROM alpine:$PENULTIMATE_ALPINE_STABLE_VERSION

ARG NGINX_VERSION="1.28.2-r0"
RUN apk add --no-cache nginx=${NGINX_VERSION}


# For testing port 80 http, remember to change the docker compose 80:80
# COPY conf/custom-nginx-80.conf /etc/nginx/http.d/z-custom-nginx.conf
COPY conf/wordpress.conf /etc/nginx/http.d/z-wordpress.conf
COPY conf/bonus/adminer.conf /etc/nginx/http.d/z-adminer.conf
COPY conf/bonus/portfolio.conf /etc/nginx/http.d/z-portfolio.conf
COPY conf/bonus/uptime-kuma.conf /etc/nginx/http.d/z-uptime-kuma.conf
COPY conf/bonus/cadvisor.conf /etc/nginx/http.d/z-cadvisor.conf

RUN mkdir -p /var/www/html /var/www/portfolio
COPY ./static /var/www/portfolio

# This makes 'docker logs' actually work, treats logs as streams instead of files, following Twelve-Factor App methodology
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 443
# EXPOSE 80

# # For testing tail -f, use time docker stop nginx and it should take at least 10 seconds
# CMD nginx && tail -f /dev/null
CMD ["nginx", "-g", "daemon off;"]
