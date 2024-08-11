#!/bin/bash

run_file_benchmark() {
    local test_category=$1
    local test_name=$2
    local bun_script=$3
    local node_script=$4
    
    echo "Running benchmark for $test_category - $test_name"
    
    mkdir -p "/app/results/$test_category"
    
    hyperfine \
        --warmup 2 \
        --min-runs 10 \
        --export-markdown "/app/results/$test_category/${test_name}_results.md" \
        --export-json "/app/results/$test_category/${test_name}_results.json" \
        --show-output \
        "bun $bun_script" \
        "bun $node_script" \
        "node $node_script"
    
    echo "Resource usage for $test_name with Bun (Bun API):"
    /usr/bin/time -v bun $bun_script 2>&1 | tee "/app/results/$test_category/${test_name}_bun_bun_api_resources.txt"
    
    echo "Resource usage for $test_name with Bun (Node.js API):"
    /usr/bin/time -v bun $node_script 2>&1 | tee "/app/results/$test_category/${test_name}_bun_node_api_resources.txt"
    
    echo "Resource usage for $test_name with Node:"
    /usr/bin/time -v node $node_script 2>&1 | tee "/app/results/$test_category/${test_name}_node_resources.txt"
}

# Create main results directory
mkdir -p "/app/results/file"

# Run benchmarks for file tests
run_file_benchmark "single_large_json_parse" "parse_json" "/app/tests/file/single_large_json_parse/parse_json_bun.js" "/app/tests/file/single_large_json_parse/parse_json_node.js"
run_file_benchmark "compress" "compress" "/app/tests/file/compress/compress_bun.js" "/app/tests/file/compress/compress_node.js"
run_file_benchmark "small_files" "small_files_sequential" "/app/tests/file/small_files/small_files_sequential_bun.js" "/app/tests/file/small_files/small_files_sequential_node.js"
run_file_benchmark "small_files" "small_files_parallel" "/app/tests/file/small_files/small_files_parallel_bun.js" "/app/tests/file/small_files/small_files_parallel_node.js"

echo "File tests completed. Results are saved in their respective directories under /app/results."