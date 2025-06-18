FROM chainguard/curl

WORKDIR /app

COPY cloudflare_ddns.sh .

RUN chmod +x cloudflare_ddns.sh

CMD ["/app/cloudflare_ddns.sh"] 