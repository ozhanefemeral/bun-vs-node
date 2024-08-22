#!/bin/bash

run_file_benchmark() {
    local test_category=$1
    local test_name=$2
    local bun_script=$3
    local node_script=$4
    
    echo "Running benchmark for $test_category - $test_name"
    
    mkdir -p "/results/$test_category"
    
    hyperfine \
        --warmup 3 \
        --min-runs 100 \
        --export-markdown "/results/$test_category/${test_name}_results.md" \
        --export-json "/results/$test_category/${test_name}_results.json" \
        --show-output \
        "bun $bun_script" \
        "bun $node_script" \
        "node $node_script"
    
    echo "Resource usage for $test_name with Bun (Bun API):"
    /usr/bin/time -v bun $bun_script 2>&1 | tee "/results/$test_category/${test_name}_bun_bun_api_resources.txt"
    
    echo "Resource usage for $test_name with Bun (Node.js API):"
    /usr/bin/time -v bun $node_script 2>&1 | tee "/results/$test_category/${test_name}_bun_node_api_resources.txt"
    
    echo "Resource usage for $test_name with Node:"
    /usr/bin/time -v node $node_script 2>&1 | tee "/results/$test_category/${test_name}_node_resources.txt"
}

mkdir -p "/results/file"

echo "Generating test files..."

# Check if both very_large_data.csv and very_large_data.json exist, if not generate them
if [ ! -f "/test_data/very_large_data.csv" ] || [ ! -f "/test_data/very_large_data.json" ]; then
    echo "Generating very_large_data.csv and very_large_data.json..."
    bun /utils/generate_very_large_files.js
else
    echo "Skipping generation of very_large_data.csv and very_large_data.json (both already exist)"
fi

# Check if small_files directory exists, if not generate it
if [ ! -d "/test_data/small_files" ]; then
    echo "Generating small_files directory..."
    bun /utils/generate_small_files.js
else
    echo "Skipping generation of small_files (directory already exists)"
fi

# Check if large_data.json exists, if not generate it
if [ ! -f "/test_data/large_data.json" ]; then
    echo "Generating large_data.json..."
    bun /utils/generate_large_json.js
else
    echo "Skipping generation of large_data.json (file already exists)"
fi

echo "Starting read tests..."

run_file_benchmark "single_large_json_parse" "parse_json" "/tests/file/single_large_json_parse/parse_json_bun.js" "/tests/file/single_large_json_parse/parse_json_node.js"
run_file_benchmark "compress" "compress" "/tests/file/compress/compress_bun.js" "/tests/file/compress/compress_node.js"
run_file_benchmark "small_files" "small_files_sequential" "/tests/file/small_files/small_files_sequential_bun.js" "/tests/file/small_files/small_files_sequential_node.js"
run_file_benchmark "small_files" "small_files_parallel" "/tests/file/small_files/small_files_parallel_bun.js" "/tests/file/small_files/small_files_parallel_node.js"

echo "Starting large file read tests..."
run_file_benchmark "very_large_file_read" "very_large_csv_read" "/tests/file/very_large_file_read/csv_read_bun.js" "/tests/file/very_large_file_read/csv_read_node.js"
run_file_benchmark "very_large_file_read" "very_large_json_read" "/tests/file/very_large_file_read/json_read_bun.js" "/tests/file/very_large_file_read/json_read_node.js"

echo "Large file read tests completed."

echo "Read tests completed."

echo "Starting write tests..."

run_file_benchmark "write_small_files" "write_small_files" "/tests/file/write_small_files/write_small_files_bun.js" "/tests/file/write_small_files/write_small_files_node.js"
run_file_benchmark "write_large_file" "write_large_file" "/tests/file/write_large_file/write_large_file_bun.js" "/tests/file/write_large_file/write_large_file_node.js"

echo "Write tests completed."
echo "All file tests completed. Results are saved in their respective directories under /results."
