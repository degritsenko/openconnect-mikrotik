FROM alpine:latest

RUN set -xe \
    && apk add --no-cache \
        nettle \
        openconnect \
    && rm -rf /var/cache/apk/*

COPY connect.sh /root/connect.sh
RUN chmod +x /root/connect.sh

HEALTHCHECK --start-period=15s --retries=1 \
  CMD pgrep openconnect || exit 1

CMD ["sh", "-c", "/root/connect.sh -D && ip addr && sh && tail -f /dev/null"]