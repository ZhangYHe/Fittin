#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SUPABASE_URL="${SUPABASE_URL:-https://supabase.yimelo.cc}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH}"
FITTIN_SERVICE_LABEL="${FITTIN_SERVICE_LABEL:-com.yimelo.fittin-web}"
CLOUDFLARED_SERVICE_LABEL="${CLOUDFLARED_SERVICE_LABEL:-homebrew.mxcl.cloudflared}"
RESTART_SUPABASE=0
RESTART_CLOUDFLARED=0

usage() {
  cat <<'EOF'
Usage:
  tool/update_public_web.sh [--restart-supabase] [--restart-cloudflared]

Defaults:
  SUPABASE_URL=https://supabase.yimelo.cc
  SUPABASE_ANON_KEY=<current publishable key>
  FITTIN_SERVICE_LABEL=com.yimelo.fittin-web
  CLOUDFLARED_SERVICE_LABEL=homebrew.mxcl.cloudflared

Environment overrides:
  SUPABASE_URL
  SUPABASE_ANON_KEY
  FITTIN_SERVICE_LABEL
  CLOUDFLARED_SERVICE_LABEL
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --restart-supabase)
      RESTART_SUPABASE=1
      shift
      ;;
    --restart-cloudflared)
      RESTART_CLOUDFLARED=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

cd "$REPO_ROOT"

echo "==> Pulling latest code"
git pull --ff-only

if [[ "$RESTART_SUPABASE" -eq 1 ]]; then
  echo "==> Restarting local Supabase"
  supabase stop
  supabase start
fi

echo "==> Building public web bundle"
"$REPO_ROOT/tool/build_web_release.sh" "$SUPABASE_URL" "$SUPABASE_ANON_KEY"

echo "==> Restarting public web service: $FITTIN_SERVICE_LABEL"
launchctl kickstart -k "gui/$(id -u)/$FITTIN_SERVICE_LABEL"

if [[ "$RESTART_CLOUDFLARED" -eq 1 ]]; then
  echo "==> Restarting cloudflared: $CLOUDFLARED_SERVICE_LABEL"
  launchctl kickstart -k "gui/$(id -u)/$CLOUDFLARED_SERVICE_LABEL"
fi

echo "==> Quick checks"
curl -I --max-time 10 http://127.0.0.1:4173
echo
curl -I --max-time 20 https://fittin.yimelo.cc/
echo
curl -I --max-time 20 https://supabase.yimelo.cc/auth/v1/settings

cat <<'EOF'

Done.

Typical usage:
  tool/update_public_web.sh

If you changed Supabase config locally:
  tool/update_public_web.sh --restart-supabase

If you changed cloudflared ingress/config:
  tool/update_public_web.sh --restart-cloudflared
EOF
