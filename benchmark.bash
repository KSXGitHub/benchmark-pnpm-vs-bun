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
pnpm install

pnpm_store=/root/.local/share/pnpm/store/
bun_cache=/root/.bun/install/cache/
pnpm_cmd_prefix='pnpm install --prefer-offline --ignore-scripts --reporter=silent'
bun_cmd_prefix='bun install --silent'

echo '[INFO] Preparing lockfile and cache for pnpm...' >&2
pnpm install --prefer-offline --ignore-scripts
rm -rf node_modules

echo '[INFO] Preparing lockfile and cache for bun...' >&2
bun install
rm -rf node_modules

echo '[MAIN] Benchmark: With lockfile and cache' >&2
hyperfine --warmup=2 \
  --prepare="rm -rf node_modules" \
  "$pnpm_cmd_prefix --frozen-lockfile" \
  "$bun_cmd_prefix --frozen-lockfile"

echo '[MAIN] Benchmark: With lockfile but without cache' >&2
hyperfine --warmup=2 \
  --prepare="rm -rf node_modules $pnpm_store $bun_cache" \
  "$pnpm_cmd_prefix --frozen-lockfile" \
  "$bun_cmd_prefix --frozen-lockfile"

echo '[MAIN] Benchmark: Without lockfile and cache' >&2
hyperfine --warmup=2 \
  --prepare="rm -rf node_modules pnpm-lock.yaml bun.lockb $pnpm_store $bun_cache" \
  "$pnpm_cmd_prefix" \
  "$bun_cmd_prefix"
