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

echo "Generating test files..."
bun /app/utils/generate_very_large_files.js
bun /app/utils/generate_small_files.js
bun /app/utils/generate_large_json.js

echo "Starting read tests..."

# Run benchmarks for read tests
run_file_benchmark "single_large_json_parse" "parse_json" "/app/tests/file/single_large_json_parse/parse_json_bun.js" "/app/tests/file/single_large_json_parse/parse_json_node.js"
run_file_benchmark "compress" "compress" "/app/tests/file/compress/compress_bun.js" "/app/tests/file/compress/compress_node.js"
run_file_benchmark "small_files" "small_files_sequential" "/app/tests/file/small_files/small_files_sequential_bun.js" "/app/tests/file/small_files/small_files_sequential_node.js"
run_file_benchmark "small_files" "small_files_parallel" "/app/tests/file/small_files/small_files_parallel_bun.js" "/app/tests/file/small_files/small_files_parallel_node.js"

echo "Starting large file read tests..."
# Run benchmarks for large file read tests
run_file_benchmark "very_large_file_read" "very_large_csv_read" "/app/tests/file/very_large_file_read/csv_read_bun.js" "/app/tests/file/very_large_file_read/csv_read_node.js"
run_file_benchmark "very_large_file_read" "very_large_json_read" "/app/tests/file/very_large_file_read/json_read_bun.js" "/app/tests/file/very_large_file_read/json_read_node.js"

echo "Large file read tests completed."

echo "Read tests completed."
echo "Starting write tests..."

# Run benchmarks for write tests
run_file_benchmark "write_small_files" "write_small_files" "/app/tests/file/write_small_files/write_small_files_bun.js" "/app/tests/file/write_small_files/write_small_files_node.js"
run_file_benchmark "write_large_file" "write_large_file" "/app/tests/file/write_large_file/write_large_file_bun.js" "/app/tests/file/write_large_file/write_large_file_node.js"

echo "Write tests completed."
echo "All file tests completed. Results are saved in their respective directories under /app/results."