#!/bin/bash
set -o errexit -o nounset -o pipefail
cd "$(dirname "$0")"

echo '[INFO] Starting verdaccio...'   >&2
verdaccio --listen=7777 1>/verdaccio.stdout.log 2>/verdaccio.stderr.log &
for countdown in {5..1}; do
  printf '%s... ' "$countdown" >&2
  sleep 1
done
echo >&2

echo '[INFO] Initializing verdaccio cache...' >&2
pnpm install --ignore-scripts
bun install

echo '[INFO] Cleaning up...' >&2
rm -rf node_modules pnpm-lock.yaml bun.lockb /root/.local/share/pnpm/store/ /root/.bun/install/cache/
