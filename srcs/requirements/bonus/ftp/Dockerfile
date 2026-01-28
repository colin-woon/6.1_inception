ARG PENULTIMATE_ALPINE_STABLE_VERSION="3.22"
FROM alpine:${PENULTIMATE_ALPINE_STABLE_VERSION}

RUN apk add --no-cache vsftpd
RUN mkdir -p /var/run/vsftpd/empty && chmod 555 /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf

COPY tools/setup_ftp.sh /usr/local/bin/setup_ftp.sh
RUN chmod +x /usr/local/bin/setup_ftp.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["setup_ftp.sh"]
