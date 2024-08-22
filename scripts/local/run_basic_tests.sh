#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

run_basic_benchmark() {
    local test_name=$1
    local script=$2
    
    echo "Running benchmark for $test_name"
    
    mkdir -p "$SCRIPT_DIR/../../results/$test_name"
    
    hyperfine \
        --warmup 2 \
        --min-runs 10 \
        --export-markdown "$SCRIPT_DIR/../../results/$test_name/${test_name}_results.md" \
        --export-json "$SCRIPT_DIR/../../results/$test_name/${test_name}_results.json" \
        --show-output \
        "bun $script" \
        "node $script"
    
    echo "Resource usage for $test_name with Bun:"
    /usr/bin/time -v bun $script 2>&1 | tee "$SCRIPT_DIR/../../results/$test_name/${test_name}_bun_resources.txt"
    
    echo "Resource usage for $test_name with Node:"
    /usr/bin/time -v node $script 2>&1 | tee "$SCRIPT_DIR/../../results/$test_name/${test_name}_node_resources.txt"
}

mkdir -p "$SCRIPT_DIR/../../results/basic"

run_basic_benchmark "while_loop" "$SCRIPT_DIR/../../tests/basic/while_loop.js"
run_basic_benchmark "fibonacci" "$SCRIPT_DIR/../../tests/basic/fibonacci.js"

echo "Basic tests completed. Results are saved in their respective directories under /results."