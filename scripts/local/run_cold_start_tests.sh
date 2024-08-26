#!/bin/bash

BASE_DIR="$(pwd)"
RESULTS_DIR="$BASE_DIR/results/cold_start"

mkdir -p "$RESULTS_DIR"

run_cold_start_benchmark() {
    local framework=$1
    local bun_create_command=$2
    local npm_create_command=$3
    local bun_build_command=$4
    local npm_build_command=$5
    
    echo "Running cold start benchmark for $framework"
    
    hyperfine --warmup 3 \
              --min-runs 10 \
              --export-markdown "$RESULTS_DIR/${framework}_results.md" \
              --export-json "$RESULTS_DIR/${framework}_results.json" \
              --prepare "rm -rf ./test-project" \
              "mkdir test-project && cd test-project && $bun_create_command && cd * && $bun_build_command" \
              "mkdir test-project && cd test-project && $npm_create_command && cd * && $npm_build_command"
    
    rm -rf ./test-project
}

# Next.js benchmark
run_cold_start_benchmark "nextjs" \
    "bun create next-app ozzy --ts --eslint --app --tailwind --no-src-dir --no-import-alias" \
    "npx create-next-app@latest ozzy --typescript --eslint --app --tailwind --no-src-dir --no-import-alias" \
    "bun run build" \
    "npm run build"

# Vite benchmark
run_cold_start_benchmark "vite" \
    "bun create vite my-vue-app --template react" \
    "npm create vite@latest my-vue-app -- --template react" \
    "bun install && bun run build" \
    "npm install && npm run build"

echo "Cold start benchmarks completed. Results are saved in $RESULTS_DIR"