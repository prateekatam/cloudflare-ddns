FROM alpine/curl:8.14.1

WORKDIR /app

COPY cloudflare_ddns.sh .

RUN apk search -v jq && \
    apk add --no-cache jq=1.7.1 && \
    chmod +x /app/cloudflare_ddns.sh
    

CMD ["/app/cloudflare_ddns.sh"] 