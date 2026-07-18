#!/usr/bin/env bash
# Seal the local secret.yml into the committed 01-sealed-secret.yml.
#
# Prerequisites:
#   - kubeseal installed (make install-sealed-secrets)
#   - kubectl pointed at the cluster running the sealed-secrets controller
#   - secret.yml filled in from secret.yml.example
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f secret.yml ]]; then
  echo "secret.yml not found. Copy secret.yml.example to secret.yml and fill it in." >&2
  exit 1
fi

kubeseal --format yaml < secret.yml > 01-sealed-secret.yml

echo "Wrote 01-sealed-secret.yml"
