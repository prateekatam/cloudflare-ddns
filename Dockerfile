FROM chainguard/curl@sha256:57e28318aee0c29ec031d42938ae37177e0b432f9988c1174b589e5b89e26cb7

WORKDIR /app

COPY cloudflare_ddns.sh .

RUN chmod +x cloudflare_ddns.sh

CMD ["/app/cloudflare_ddns.sh"] 