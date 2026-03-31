#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  cat <<'EOF'
Usage:
  tool/build_web_release.sh <SUPABASE_URL> <SUPABASE_ANON_KEY>

Example:
  tool/build_web_release.sh https://your-project.supabase.co your-anon-key

See docs/web-public-deployment.md for the full deployment flow.
EOF
  exit 1
fi

SUPABASE_URL="$1"
SUPABASE_ANON_KEY="$2"

echo "==> Normalizing Isar web schema ids"
dart tool/fix_isar_web_schema_ids.dart

echo "==> Building Flutter web release"
flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

BUILD_VERSION="$(date +%s)"
python3 - <<'PY' "$BUILD_VERSION"
from pathlib import Path
import re
import sys

version = sys.argv[1]
bootstrap_path = Path("build/web/flutter_bootstrap.js")
bootstrap_text = bootstrap_path.read_text()
bootstrap_updated = re.sub(
    r'"mainJsPath":"main\.dart\.js"',
    f'"mainJsPath":"main.dart.js?v={version}"',
    bootstrap_text,
    count=1,
)
if bootstrap_updated == bootstrap_text:
    raise SystemExit("Failed to inject versioned main.dart.js path into flutter_bootstrap.js")
bootstrap_path.write_text(bootstrap_updated)

index_path = Path("build/web/index.html")
index_text = index_path.read_text()
index_updated = index_text.replace(
    '<script src="flutter_bootstrap.js" async></script>',
    f'<script src="flutter_bootstrap.js?v={version}" async></script>',
    1,
)
if index_updated == index_text:
    raise SystemExit("Failed to inject versioned flutter_bootstrap.js path into index.html")
index_path.write_text(index_updated)

print(f"Injected bootstrap/main cache-busting query: v={version}")
PY

cat <<'EOF'

Build complete.
Next steps:
1. Start Caddy: caddy run --config deploy/caddy/fittin.Caddyfile
2. Verify local origin: http://127.0.0.1:4173
3. Confirm Cloudflare Tunnel routes fittin.yimelo.cc to 127.0.0.1:4173
4. Follow docs/web-public-deployment.md for smoke checks and rollback
EOF
