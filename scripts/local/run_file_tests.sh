#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Set the TEST_DATA_PATH environment variable
export TEST_DATA_PATH="$BASE_DIR/test_data"

run_file_benchmark() {
    local test_category=$1
    local test_name=$2
    local bun_script=$3
    local node_script=$4
    
    echo "Running benchmark for $test_category - $test_name"
    
    mkdir -p "$BASE_DIR/results/$test_category"
    
    hyperfine \
        --warmup 3 \
        --min-runs 100 \
        --export-markdown "$BASE_DIR/results/$test_category/${test_name}_results.md" \
        --export-json "$BASE_DIR/results/$test_category/${test_name}_results.json" \
        --show-output \
        "TEST_DATA_PATH=$TEST_DATA_PATH bun $bun_script" \
        "TEST_DATA_PATH=$TEST_DATA_PATH bun $node_script" \
        "TEST_DATA_PATH=$TEST_DATA_PATH node $node_script"
    
    echo "Resource usage for $test_name with Bun (Bun API):"
    TEST_DATA_PATH=$TEST_DATA_PATH /usr/bin/time -v bun $bun_script 2>&1 | tee "$BASE_DIR/results/$test_category/${test_name}_bun_bun_api_resources.txt"
    
    echo "Resource usage for $test_name with Bun (Node.js API):"
    TEST_DATA_PATH=$TEST_DATA_PATH /usr/bin/time -v bun $node_script 2>&1 | tee "$BASE_DIR/results/$test_category/${test_name}_bun_node_api_resources.txt"
    
    echo "Resource usage for $test_name with Node:"
    TEST_DATA_PATH=$TEST_DATA_PATH /usr/bin/time -v node $node_script 2>&1 | tee "$BASE_DIR/results/$test_category/${test_name}_node_resources.txt"
}

mkdir -p "$BASE_DIR/results/file"

echo "Generating test files..."

# Check if both very_large_data.csv and very_large_data.json exist, if not generate them
if [ ! -f "$TEST_DATA_PATH/very_large_data.csv" ] || [ ! -f "$TEST_DATA_PATH/very_large_data.json" ]; then
    echo "Generating very_large_data.csv and very_large_data.json..."
    TEST_DATA_PATH=$TEST_DATA_PATH bun $BASE_DIR/utils/generate_very_large_files.js
else
    echo "Skipping generation of very_large_data.csv and very_large_data.json (both already exist)"
fi

# Check if small_files directory exists, if not generate it
if [ ! -d "$TEST_DATA_PATH/small_files" ]; then
    echo "Generating small_files directory..."
    TEST_DATA_PATH=$TEST_DATA_PATH bun $BASE_DIR/utils/generate_small_files.js
else
    echo "Skipping generation of small_files (directory already exists)"
fi

# Check if large_data.json exists, if not generate it
if [ ! -f "$TEST_DATA_PATH/large_data.json" ]; then
    echo "Generating large_data.json..."
    TEST_DATA_PATH=$TEST_DATA_PATH bun $BASE_DIR/utils/generate_large_json.js
else
    echo "Skipping generation of large_data.json (file already exists)"
fi

# ... rest of the script remains the same ...

echo "Starting read tests..."

run_file_benchmark "single_large_json_parse" "parse_json" "$BASE_DIR/tests/file/single_large_json_parse/parse_json_bun.js" "$BASE_DIR/tests/file/single_large_json_parse/parse_json_node.js"
run_file_benchmark "compress" "compress" "$BASE_DIR/tests/file/compress/compress_bun.js" "$BASE_DIR/tests/file/compress/compress_node.js"
run_file_benchmark "small_files" "small_files_sequential" "$BASE_DIR/tests/file/small_files/small_files_sequential_bun.js" "$BASE_DIR/tests/file/small_files/small_files_sequential_node.js"
run_file_benchmark "small_files" "small_files_parallel" "$BASE_DIR/tests/file/small_files/small_files_parallel_bun.js" "$BASE_DIR/tests/file/small_files/small_files_parallel_node.js"

echo "Starting large file read tests..."
run_file_benchmark "very_large_file_read" "very_large_csv_read" "$BASE_DIR/tests/file/very_large_file_read/csv_read_bun.js" "$BASE_DIR/tests/file/very_large_file_read/csv_read_node.js"
run_file_benchmark "very_large_file_read" "very_large_json_read" "$BASE_DIR/tests/file/very_large_file_read/json_read_bun.js" "$BASE_DIR/tests/file/very_large_file_read/json_read_node.js"

echo "Large file read tests completed."

echo "Read tests completed."

echo "Starting write tests..."

run_file_benchmark "write_small_files" "write_small_files" "$BASE_DIR/tests/file/write_small_files/write_small_files_bun.js" "$BASE_DIR/tests/file/write_small_files/write_small_files_node.js"
run_file_benchmark "write_large_file" "write_large_file" "$BASE_DIR/tests/file/write_large_file/write_large_file_bun.js" "$BASE_DIR/tests/file/write_large_file/write_large_file_node.js"

echo "Write tests completed."
echo "All file tests completed. Results are saved in their respective directories under $BASE_DIR/results."