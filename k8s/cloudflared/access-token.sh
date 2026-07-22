#!/usr/bin/env bash
# Manage Cloudflare Access service tokens for API/mobile clients of any
# Access-protected app (e.g. the Immich mobile app).
#
# One token per person/device means one-click revoke: deleting a single token
# cuts off that client without affecting anyone else. The Access application
# must have a Service Auth policy whose Include is "Any Access Service Token"
# (set once in the dashboard), so creating/revoking tokens here needs NO policy
# edits.
#
# Usage:
#   ./access-token.sh create <name>   Create a token; print its headers once
#   ./access-token.sh list            List existing tokens
#   ./access-token.sh revoke <name>   Delete the token(s) with that name
#
# Config: copy cloudflare.env.example to cloudflare.env (gitignored) and set:
#   CF_API_TOKEN  - API token with "Access: Service Tokens" Edit (account scope)
#   CF_ACCOUNT_ID - your Cloudflare account ID
set -euo pipefail

cd "$(dirname "$0")"

command -v jq >/dev/null || { echo "jq is required (e.g. sudo apt-get install -y jq)" >&2; exit 1; }

if [[ -f cloudflare.env ]]; then
  # shellcheck disable=SC1091
  source ./cloudflare.env
fi
: "${CF_API_TOKEN:?not set -- copy cloudflare.env.example to cloudflare.env and fill it in}"
: "${CF_ACCOUNT_ID:?not set -- copy cloudflare.env.example to cloudflare.env and fill it in}"

API="https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/access/service_tokens"

# cf <curl-args...> -- calls the API, verifies success, echoes the JSON body.
cf() {
  local resp
  resp=$(curl -sS \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" "$@")
  if [[ "$(jq -r '.success' <<<"$resp" 2>/dev/null)" != "true" ]]; then
    echo "Cloudflare API error:" >&2
    jq -r '.errors // .' <<<"$resp" >&2 2>/dev/null || echo "$resp" >&2
    exit 1
  fi
  echo "$resp"
}

case "${1:-}" in
  create)
    name="${2:?usage: $0 create <name>}"
    resp=$(cf -X POST "$API" --data "$(jq -n --arg n "$name" '{name:$n}')")
    cid=$(jq -r '.result.client_id' <<<"$resp")
    sec=$(jq -r '.result.client_secret' <<<"$resp")
    echo "Created service token '$name'."
    echo "Add these headers in the client (e.g. the Immich app's Custom Proxy Headers):"
    echo
    echo "  CF-Access-Client-Id      = $cid"
    echo "  CF-Access-Client-Secret  = $sec"
    echo
    echo "The secret is shown ONCE. If lost, revoke this token and create a new one."
    ;;
  list)
    cf -X GET "$API" \
      | jq -r '.result[] | "\(.id)\t\(.name)\tcreated=\(.created_at)"' \
      | { column -t -s "$(printf '\t')" 2>/dev/null || cat; }
    ;;
  revoke)
    name="${2:?usage: $0 revoke <name>}"
    ids=$(cf -X GET "$API" | jq -r --arg n "$name" '.result[] | select(.name==$n) | .id')
    [[ -n "$ids" ]] || { echo "No token named '$name'." >&2; exit 1; }
    for id in $ids; do
      cf -X DELETE "$API/$id" >/dev/null
      echo "Revoked token '$name' ($id)."
    done
    ;;
  *)
    echo "Usage: $0 {create <name>|list|revoke <name>}" >&2
    exit 1
    ;;
esac
