#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
RESULTS_DIR="$PROJECT_ROOT/results"

run_basic_benchmark() {
    local test_name=$1
    local script=$2
    
    echo "Running benchmark for $test_name"
    
    mkdir -p "$RESULTS_DIR/basic/$test_name"
    
    hyperfine \
        --warmup 2 \
        --min-runs 10 \
        --export-markdown "$RESULTS_DIR/basic/$test_name/${test_name}_results.md" \
        --export-json "$RESULTS_DIR/basic/$test_name/${test_name}_results.json" \
        --show-output \
        "bun $script" \
        "node $script"
    
    echo "Resource usage for $test_name with Bun:"
    /usr/bin/time -v bun $script 2>&1 | tee "$RESULTS_DIR/basic/$test_name/${test_name}_bun_resources.txt"
    
    echo "Resource usage for $test_name with Node:"
    /usr/bin/time -v node $script 2>&1 | tee "$RESULTS_DIR/basic/$test_name/${test_name}_node_resources.txt"
}

mkdir -p "$RESULTS_DIR/basic"

run_basic_benchmark "while_loop" "$PROJECT_ROOT/tests/basic/while_loop.js"
run_basic_benchmark "fibonacci" "$PROJECT_ROOT/tests/basic/fibonacci.js"
run_basic_benchmark "large_array" "$PROJECT_ROOT/tests/basic/large_array.js"
run_basic_benchmark "stringify" "$PROJECT_ROOT/tests/basic/stringify.js"

echo "Basic tests completed. Results are saved in their respective directories under $RESULTS_DIR/basic."