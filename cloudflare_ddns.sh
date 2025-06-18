#!/bin/sh

# Cloudflare API details
ZONE_ID="${CLOUDFLARE_ZONE_ID}"
CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN}"


# Record details
RECORD_NAME="${CLOUDFLARE_RECORD_NAME}"
CLOUDFLARE_TTL="${CLOUDFLARE_TTL:-1}" # Default to 1 (automatic) if not set. If set, must be between 60 and 86400
CLOUDFLARE_PROXIED="${CLOUDFLARE_PROXIED:-true}" # Default to true if not set

# Fetch DNS records to find the ID and current IP
DNS_RECORDS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
     -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
     -H "Content-Type: application/json")


# Check if DNS_RECORDS is valid JSON and not empty
if ! echo "${DNS_RECORDS}" | jq -e . >/dev/null 2>&1; then
  echo "Error: Failed to fetch DNS records or invalid JSON response from Cloudflare API."
  echo "Response: ${DNS_RECORDS}"
  exit 1
fi

RECORD_ID=$(echo "${DNS_RECORDS}" | jq -r '.result[] | select(.name=="'"${RECORD_NAME}"'" and .type=="A") | .id')
CLOUDFLARE_IP=$(echo "${DNS_RECORDS}" | jq -r '.result[] | select(.name=="'"${RECORD_NAME}"'" and .type=="A") | .content')

# Check if RECORD_ID was found
if [ -z "${RECORD_ID}" ]; then
  echo "Error: DNS record with name '${RECORD_NAME}' and type 'A' not found in Cloudflare zone '${ZONE_ID}'."
  echo "Details of A records found in zone '${ZONE_ID}':"
  echo "${DNS_RECORDS}" | jq -r '.result[] | select(.type=="A") | "  - Name: \(.name), Content: \(.content), TTL: \(.ttl), Proxied: \(.proxied), ID: \(.id)"'
  exit 1
fi

# Get current public IP address
CURRENT_IP=$(curl -s https://api.ipify.org)

echo "Record ID: ${RECORD_ID}"
echo "Current IP: ${CURRENT_IP}"
echo "Cloudflare IP: ${CLOUDFLARE_IP}"

CURRENT_DATE=$(date +"%d:%m:%Y %H:%M:%S")

# Compare IPs and update if different
if [ "${CURRENT_IP}" != "${CLOUDFLARE_IP}" ]; then
  echo "IP address has changed. Updating Cloudflare DNS..."
  UPDATE_RESPONSE=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
       -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
       -H "Content-Type: application/json" \
       --data '{
         "type":"A",
         "name":"'"${RECORD_NAME}"'",
         "content":"'"${CURRENT_IP}"'",
         "proxied":'"${CLOUDFLARE_PROXIED}"',
         "ttl":'"${CLOUDFLARE_TTL}"',
         "comment":"Updated by DDNS script at '"${CURRENT_DATE}"'"
       }')

  if echo "${UPDATE_RESPONSE}" | grep -q '"success":true'; then
    echo "Cloudflare DNS updated successfully to ${CURRENT_IP}"
  else
    echo "Failed to update Cloudflare DNS: ${UPDATE_RESPONSE}"
  fi
else
  echo "IP address has not changed. No update needed."
fi