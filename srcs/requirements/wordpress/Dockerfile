ARG PENULTIMATE_DEBIAN_STABLE_VERSION="bookworm-slim"
FROM debian:$PENULTIMATE_DEBIAN_STABLE_VERSION

ARG PHP_VERSION=8.2
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	php${PHP_VERSION}-fpm \
	php${PHP_VERSION}-mysql \
	mariadb-client \
	curl \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php && mkdir -p /var/www/html

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

COPY conf/z-custom-www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/z-custom-www.conf

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
