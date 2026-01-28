ARG PENULTIMATE_ALPINE_STABLE_VERSION="3.22"
FROM alpine:${PENULTIMATE_ALPINE_STABLE_VERSION}

# 1. Install PHP and minimal extensions
# We add php82-common and php82-pdo_mysql for better DB compatibility
RUN apk add --no-cache \
    php82 \
	php82-common \
    php82-mysqli \
    php82-pdo_mysql \
    php82-session \
    php82-json \
    curl

# 2. Create a dedicated user for security (Non-root)
RUN addgroup -S adminer && adduser -S adminer -G adminer

# 3. Setup Working Directory
WORKDIR /var/www/html

# 4. Download Adminer and set permissions immediately
# Using curl -L to follow redirects (adminer.org often redirects)
RUN curl -L "https://www.adminer.org/latest.php" -o index.php && \
    chown -R adminer:adminer /var/www/html && \
    chmod -R 755 /var/www/html

# 5. Switch to the non-root user
USER adminer

# 6. Expose the port
EXPOSE 8080

# Run the PHP built-in web server
# -S 0.0.0.0:8080 : Listen on all interfaces inside the container
# -t /var/www/html : Serve files from this directory
CMD ["php82", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]