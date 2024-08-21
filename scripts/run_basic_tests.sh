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

mkdir -p "/app/results/basic"

run_basic_benchmark "while_loop" "/app/tests/basic/while_loop.js"
run_basic_benchmark "fibonacci" "/app/tests/basic/fibonacci.js"

echo "Basic tests completed. Results are saved in their respective directories under /app/results."