#!/usr/bin/env bash
# Render 02-configmap.yml (gitignored) from the committed template
# 02-configmap.yml.tmpl, substituting your local values from config.env.
# This keeps your public hostnames out of git.
#
# Every KEY=value in config.env becomes a __KEY__ -> value substitution in the
# template. So exposing another service is just: add its hostname as a new var
# (e.g. DOMAIN_FOO=foo.example.com) and reference __DOMAIN_FOO__ in the template
# -- no edits to this script needed.
#
# Prerequisites:
#   - config.env filled in from config.env.example
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f config.env ]]; then
  echo "config.env not found. Copy config.env.example to config.env and fill it in." >&2
  exit 1
fi

# shellcheck disable=SC1091
source ./config.env

: "${TUNNEL_ID:?TUNNEL_ID not set in config.env}"

# The tunnel ID must be the plain UUID (the token's 't' field), not base64.
# A base64-encoded value makes cloudflared treat it as a tunnel *name* and
# demand an origin cert.pem at runtime, which fails cryptically.
uuid_re='^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
if [[ ! "$TUNNEL_ID" =~ $uuid_re ]]; then
  echo "ERROR: TUNNEL_ID is not a UUID: '$TUNNEL_ID'" >&2
  echo "  It must be the plain tunnel UUID (the decoded token's 't' field)," >&2
  echo "  e.g. 123e4567-e89b-12d3-a456-426614174000." >&2
  if decoded=$(printf '%s' "$TUNNEL_ID" | base64 -d 2>/dev/null) && [[ "$decoded" =~ $uuid_re ]]; then
    echo "  Hint: your value base64-decodes to '$decoded' -- use that instead." >&2
  fi
  exit 1
fi

# Substitute __KEY__ -> value for every KEY=... defined in config.env.
mapfile -t keys < <(grep -oE '^[A-Za-z_][A-Za-z0-9_]*=' config.env | sed 's/=$//')
sed_args=()
for key in "${keys[@]}"; do
  val="${!key}"
  # Escape characters special to sed's replacement string.
  esc=${val//\\/\\\\}
  esc=${esc//&/\\&}
  esc=${esc//|/\\|}
  sed_args+=(-e "s|__${key}__|${esc}|g")
done

sed "${sed_args[@]}" 02-configmap.yml.tmpl > 02-configmap.yml

# Guard: fail if any placeholder was left unsubstituted (missing config.env var).
if grep -qE '__[A-Za-z_][A-Za-z0-9_]*__' 02-configmap.yml; then
  echo "ERROR: unsubstituted placeholder(s) in 02-configmap.yml -- add them to config.env:" >&2
  grep -oE '__[A-Za-z_][A-Za-z0-9_]*__' 02-configmap.yml | sort -u >&2
  rm -f 02-configmap.yml
  exit 1
fi

echo "Wrote 02-configmap.yml"
