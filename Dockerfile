FROM alpine/curl:8.14.1

WORKDIR /app

COPY cloudflare_ddns.sh .

RUN chmod +x /app/cloudflare_ddns.sh && \
    apk add --no-cache jq=1.6

CMD ["/app/cloudflare_ddns.sh"] 