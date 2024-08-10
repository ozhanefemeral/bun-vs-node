#!/bin/bash

run_basic_benchmark() {
    local test_name=$1
    local script=$2
    
    echo "Running benchmark for $test_name"
    
    mkdir -p "/app/results/$test_name"
    
    hyperfine \
        --warmup 2 \
        --min-runs 10 \
        --export-markdown "/app/results/$test_name/${test_name}_results.md" \
        --export-json "/app/results/$test_name/${test_name}_results.json" \
        --show-output \
        "bun $script" \
        "node $script"
    
    echo "Resource usage for $test_name with Bun:"
    /usr/bin/time -v bun $script 2>&1 | tee "/app/results/$test_name/${test_name}_bun_resources.txt"
    
    echo "Resource usage for $test_name with Node:"
    /usr/bin/time -v node $script 2>&1 | tee "/app/results/$test_name/${test_name}_node_resources.txt"
}

run_file_benchmark() {
    local test_name=$1
    local bun_script=$2
    local node_script=$3
    
    echo "Running benchmark for $test_name"
    
    mkdir -p "/app/results/$test_name"
    
    hyperfine \
        --warmup 2 \
        --min-runs 10 \
        --export-markdown "/app/results/$test_name/${test_name}_results.md" \
        --export-json "/app/results/$test_name/${test_name}_results.json" \
        --show-output \
        "bun $bun_script" \
        "bun $node_script" \
        "node $node_script"
    
    echo "Resource usage for $test_name with Bun (Bun API):"
    /usr/bin/time -v bun $bun_script 2>&1 | tee "/app/results/$test_name/${test_name}_bun_bun_api_resources.txt"
    
    echo "Resource usage for $test_name with Bun (Node.js API):"
    /usr/bin/time -v bun $node_script 2>&1 | tee "/app/results/$test_name/${test_name}_bun_node_api_resources.txt"
    
    echo "Resource usage for $test_name with Node:"
    /usr/bin/time -v node $node_script 2>&1 | tee "/app/results/$test_name/${test_name}_node_resources.txt"
}

# Ensure both Bun and Node.js are available
if ! command -v bun &> /dev/null || ! command -v node &> /dev/null; then
    echo "Both Bun and Node.js are required to run these tests. Exiting."
    exit 1
fi

# Create main results directory
mkdir -p "/app/results"

# Run benchmarks for basic tests
run_basic_benchmark "while_loop" "/app/tests/basic/while_loop.js"
run_basic_benchmark "fibonacci" "/app/tests/basic/fibonacci.js"

# Run benchmarks for file tests
run_file_benchmark "parse_json" "/app/tests/file/parse_json_bun.js" "/app/tests/file/parse_json_node.js"
run_file_benchmark "compress" "/app/tests/file/compress_bun.js" "/app/tests/file/compress_node.js"

echo "All tests completed. Results are saved in their respective directories under /app/results."