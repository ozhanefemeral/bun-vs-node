#!/bin/bash

# Configuration
CONNECTIONS=1250
REQUESTS=1000000

BUN_IP="164.92.132.234"
NODE_IP="64.226.107.21"
PORT=6693

# Assume we have 1,000,000 users (must be same with database records)
MAX_USER_ID=1000000

mkdir -p "/results/http"

run_http_benchmark() {
    local test_name=$1
    local path=$2
    local query_params=$3
    
    echo "Running benchmark for $test_name"
    
    mkdir -p "/results/http/$test_name"
    
    local full_path="$path"
    if [[ -n "$query_params" ]]; then
        full_path="${path}?${query_params}"
    fi
    
    # Generate a random user ID for user API test
    if [[ "$test_name" == *"user_populated"* ]]; then
        local bun_random_id=$((RANDOM % MAX_USER_ID + 1))
        local node_random_id=$((RANDOM % MAX_USER_ID + 1))
        bun_full_path="${full_path}${bun_random_id}"
        node_full_path="${full_path}${node_random_id}"
    else
        bun_full_path=$full_path
        node_full_path=$full_path
    fi
    
    # Run Bombardier for Bun (JSON output)
    if ! bombardier -c $CONNECTIONS -n $REQUESTS -l -p r -o json "http://$BUN_IP:$PORT$bun_full_path" > "/results/http/$test_name/${test_name}_bun_bombardier.json" 2>&1; then
        echo "Error running Bombardier for Bun test: $test_name" >&2
    fi
    
    # Run Bombardier for Node (JSON output)
    if ! bombardier -c $CONNECTIONS -n $REQUESTS -l -p r -o json "http://$NODE_IP:$PORT$node_full_path" > "/results/http/$test_name/${test_name}_node_bombardier.json" 2>&1; then
        echo "Error running Bombardier for Node test: $test_name" >&2
    fi
    
    echo "HTTP benchmark for $test_name completed. Results saved in /results/http/$test_name/"
}

if ! command -v bombardier &> /dev/null; then
    echo "Bombardier is not installed or not in PATH. Please check your Dockerfile and environment." >&2
    exit 1
fi

mkdir -p "/results/http"

run_http_benchmark "static_file_index" "/index.html"
run_http_benchmark "api_user_populated_random" "/api/user" "id="
run_http_benchmark "api_movies_query_genre" "/api/movies" "genre=sci-fi"
run_http_benchmark "api_movies_query_date_genre" "/api/movies" "date=1640995200000&genre=sci-fi"
run_http_benchmark "api_movies_query_date" "/api/movies" "date=854541091"

echo "All HTTP tests completed. Merging JSON results..."

# Run the Node script to merge HTTP results
node /utils/merge_http_results.js

echo "All HTTP tests completed and results processed. Results are saved in their respective directories under /results/http."