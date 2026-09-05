#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."

for f in build-iso.sh build-wsl.sh check_urls.sh scripts/*.sh builder/scripts/*.sh builder/scripts/lib/*.sh builder/scripts/bin/* docker/*.sh docker/scripts/*.sh; do
    if [ -f "$f" ]; then
        bash -n "$f"
        echo "Syntax OK: $f"
    fi
done

echo "=== All scripts passed bash -n syntax check! ==="
