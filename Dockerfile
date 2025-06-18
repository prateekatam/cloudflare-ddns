FROM alpine/curl:8.14.1

WORKDIR /app

COPY cloudflare_ddns.sh .

RUN chmod +x /app/cloudflare_ddns.sh
RUN apk add --no-cache jq

CMD ["/app/cloudflare_ddns.sh"] 