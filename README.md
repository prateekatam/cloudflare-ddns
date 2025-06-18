# Cloudflare DDNS Update

This project provides a simple Dockerized script to automatically update your Cloudflare DNS A record with your current public IP address. It's designed to be lightweight and easy to deploy.

## Setup and Usage

1.  **Clone this repository:**
    ```bash
    git clone https://github.com/prateekatam/cloudflare-ddns.git
    cd cloudflare-ddns
    ```

2.  **Configure Cloudflare API Tokens:**
    You need to set the following environment variables. It is highly recommended to use Cloudflare API Tokens with specific permissions rather than your global API Key for security.
    *   `CLOUDFLARE_ZONE_ID`: The ID of your Cloudflare zone.
    *   `CLOUDFLARE_API_TOKEN`: Your Cloudflare API Token with `Zone DNS` > `Edit` permissions for the specific zone.
    *   `CLOUDFLARE_RECORD_NAME`: The name of the DNS record (e.g., `your-subdomain.example.com`).
    *   `CLOUDFLARE_TTL` (Optional): Time To Live for the DNS record in seconds. Defaults to `1` (automatic). Must be between 60 and 86400 if not 1.
    *   `CLOUDFLARE_PROXIED` (Optional): Whether the record is proxied by Cloudflare (true/false). Defaults to `true`.

    **How to get `ZONE_ID` and create `API_TOKEN`:**
    You can find these by inspecting the network requests when you update a DNS record in the Cloudflare UI, or by using the Cloudflare API directly. For example, to list DNS records:
    ```bash
    curl -X GET "https://api.cloudflare.com/client/v4/zones/<YOUR_ZONE_ID>/dns_records" \
         -H "Authorization: Bearer YOUR_API_TOKEN" \
         -H "Content-Type: application/json" | jq .
    ```

3.  **Pull the Docker Image (Optional):**
    If you prefer to use the pre-built image from GitHub Container Registry, you can pull the latest version:
    ```bash
    docker pull ghcr.io/prateekatam/cloudflare-ddns:v1.0.0
    ```
    Then, when running the container (in the next step), use `ghcr.io/prateekatam/cloudflare-ddns:latest` instead of building it yourself.


3.  **Build the Docker Image:**
    Navigate to the `cloudflare-ddns` directory and build the Docker image:
    ```bash
    docker build -t cloudflare-ddns .
    ```

4.  **Run the Docker Container:**
    Run the container, passing in your Cloudflare credentials as environment variables. You can schedule this to run periodically using cron or a Kubernetes CronJob.

    ```bash
    docker run --rm \
      -e CLOUDFLARE_ZONE_ID="your_zone_id" \
      -e CLOUDFLARE_API_TOKEN="your_api_token" \
      -e CLOUDFLARE_RECORD_NAME="your.domain.com" \
      -e CLOUDFLARE_TTL="300" \
      -e CLOUDFLARE_PROXIED="true" \
      cloudflare-ddns
    ```
    Replace the placeholder values with your actual Cloudflare details. Note that if your repository is private, users will need to authenticate with GHCR (e.g., using a GitHub Personal Access Token) to pull the image.