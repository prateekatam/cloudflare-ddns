FROM alpine/curl:8.14.1

WORKDIR /app

COPY cloudflare_ddns.sh .

RUN chmod +x /app/cloudflare_ddns.sh

CMD ["/app/cloudflare_ddns.sh"] 