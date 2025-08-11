#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${OPENAI:-}" || -z "${SUPABASE_URL:-}" || -z "${SUPABASE_ANON:-}" ]]; then
  echo "Usage: OPENAI=sk-... SUPABASE_URL=https://... SUPABASE_ANON=... $0" >&2
  exit 1
fi

json=$(cat <<JSON
{"openai":"${OPENAI}","supabase_url":"${SUPABASE_URL}","supabase_anon":"${SUPABASE_ANON}"}
JSON
)

b64=$(printf '%s' "$json" | openssl base64 -A)
echo "APP_API_KEY=${b64}"