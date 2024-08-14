#!/bin/bash

# Configuration
CONNECTIONS=125
REQUESTS=100000
DURATION="10s"

run_http_benchmark() {
    local test_name=$1
    local port=$2
    local path=$3
    local bun_script=$4
    local node_script=$5
    
    echo "Running benchmark for $test_name"
    
    mkdir -p "/app/results/http/$test_name"
    
    # Start Bun server
    bun $bun_script &
    BUN_PID=$!
    sleep 2  # Give the server time to start

    # Run Bombardier for Bun (JSON output)
    if ! bombardier -c $CONNECTIONS -n $REQUESTS -d $DURATION -l -p r -o json http://localhost:$port$path > "/app/results/http/$test_name/${test_name}_bun_bombardier.json" 2>&1; then
        echo "Error running Bombardier for Bun test: $test_name" >&2
    fi
    
    # Stop Bun server
    kill $BUN_PID
    
    # Start Node server
    node $node_script &
    NODE_PID=$!
    sleep 2  # Give the server time to start

    # Run Bombardier for Node (JSON output)
    if ! bombardier -c $CONNECTIONS -n $REQUESTS -d $DURATION -l -p r -o json http://localhost:$port$path > "/app/results/http/$test_name/${test_name}_node_bombardier.json" 2>&1; then
        echo "Error running Bombardier for Node test: $test_name" >&2
    fi
    
    # Stop Node server
    kill $NODE_PID
    
    echo "HTTP benchmark for $test_name completed. Results saved in /app/results/http/$test_name/"
}

# Ensure Bombardier is available
if ! command -v bombardier &> /dev/null; then
    echo "Bombardier is not installed or not in PATH. Please check your Dockerfile and environment." >&2
    exit 1
fi

# Create main results directory
mkdir -p "/app/results/http"

# Run benchmarks for HTTP tests
run_http_benchmark "simple_server" 3000 "/" "/app/tests/http/simple_server_bun.js" "/app/tests/http/simple_server_node.js"
run_http_benchmark "json_response" 3001 "/" "/app/tests/http/json_response_bun.js" "/app/tests/http/json_response_node.js"
run_http_benchmark "routing_home" 3002 "/" "/app/tests/http/routing_bun.js" "/app/tests/http/routing_node.js"
run_http_benchmark "routing_about" 3002 "/about" "/app/tests/http/routing_bun.js" "/app/tests/http/routing_node.js"

echo "All HTTP tests completed. Merging JSON results..."

# Run the Bun script to merge HTTP results
bun /app/utils/merge_http_results.js

echo "All HTTP tests completed and results processed. Results are saved in their respective directories under /app/results/http."