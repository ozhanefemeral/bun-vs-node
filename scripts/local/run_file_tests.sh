#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
RESULTS_DIR="$PROJECT_ROOT/results/file"
TEST_DATA_PATH="$PROJECT_ROOT/test_data"

export TEST_DATA_PATH

mkdir -p "$RESULTS_DIR"
mkdir -p "$TEST_DATA_PATH"
mkdir -p "$TEST_DATA_PATH/very_large_files"
mkdir -p "$TEST_DATA_PATH/small_files"

run_file_benchmark() {
    local test_category=$1
    local test_name=$2
    local bun_script=$3
    local node_script=$4
    
    echo "Running benchmark for $test_category - $test_name"
    
    mkdir -p "$RESULTS_DIR/$test_category"
    
    hyperfine \
        --warmup 3 \
        --min-runs 100 \
        --export-markdown "$RESULTS_DIR/$test_category/${test_name}_results.md" \
        --export-json "$RESULTS_DIR/$test_category/${test_name}_results.json" \
        --show-output \
        --command-name "Bun with Bun API" "TEST_DATA_PATH=$TEST_DATA_PATH bun $bun_script" \
        --command-name "Bun with Node API" "TEST_DATA_PATH=$TEST_DATA_PATH bun $node_script" \
        --command-name "Node with Node API" "TEST_DATA_PATH=$TEST_DATA_PATH node $node_script"
    
    echo "Resource usage for $test_name with Bun (Bun API):"
    TEST_DATA_PATH=$TEST_DATA_PATH /usr/bin/time -v bun $bun_script 2>&1 | tee "$RESULTS_DIR/$test_category/${test_name}_bun_bun_api_resources.txt"
    
    echo "Resource usage for $test_name with Bun (Node.js API):"
    TEST_DATA_PATH=$TEST_DATA_PATH /usr/bin/time -v bun $node_script 2>&1 | tee "$RESULTS_DIR/$test_category/${test_name}_bun_node_api_resources.txt"
    
    echo "Resource usage for $test_name with Node:"
    TEST_DATA_PATH=$TEST_DATA_PATH /usr/bin/time -v node $node_script 2>&1 | tee "$RESULTS_DIR/$test_category/${test_name}_node_resources.txt"
}

echo "Checking and generating test files if necessary..."

if [ ! -f "$TEST_DATA_PATH/large_data.json" ]; then
    echo "Generating large_data.json..."
    TEST_DATA_PATH=$TEST_DATA_PATH bun "$PROJECT_ROOT/utils/generate_large_json.js"
else
    echo "large_data.json already exists, skipping generation."
fi

if [ ! -f "$TEST_DATA_PATH/very_large_files/very_large_data.csv" ] || [ ! -f "$TEST_DATA_PATH/very_large_files/very_large_data.json" ]; then
    echo "Generating very_large_data.csv and very_large_data.json..."
    TEST_DATA_PATH=$TEST_DATA_PATH bun "$PROJECT_ROOT/utils/generate_very_large_files.js"
else
    echo "very_large_data.csv and very_large_data.json already exist, skipping generation."
fi

if [ ! "$(ls -A "$TEST_DATA_PATH/small_files")" ]; then
    echo "Generating small files..."
    TEST_DATA_PATH=$TEST_DATA_PATH bun "$PROJECT_ROOT/utils/generate_small_files.js"
else
    echo "Small files already exist, skipping generation."
fi

echo "Test data check completed."

echo "Starting read tests..."

run_file_benchmark "single_large_json_parse" "parse_json" "$PROJECT_ROOT/tests/file/single_large_json_parse/parse_json_bun.js" "$PROJECT_ROOT/tests/file/single_large_json_parse/parse_json_node.js"
run_file_benchmark "compress" "compress" "$PROJECT_ROOT/tests/file/compress/compress_bun.js" "$PROJECT_ROOT/tests/file/compress/compress_node.js"
run_file_benchmark "small_files" "small_files_sequential" "$PROJECT_ROOT/tests/file/small_files/small_files_sequential_bun.js" "$PROJECT_ROOT/tests/file/small_files/small_files_sequential_node.js"
run_file_benchmark "small_files" "small_files_parallel" "$PROJECT_ROOT/tests/file/small_files/small_files_parallel_bun.js" "$PROJECT_ROOT/tests/file/small_files/small_files_parallel_node.js"

echo "Starting large file read tests..."
run_file_benchmark "very_large_file_read" "very_large_csv_read" "$PROJECT_ROOT/tests/file/very_large_file_read/csv_read_bun.js" "$PROJECT_ROOT/tests/file/very_large_file_read/csv_read_node.js"
run_file_benchmark "very_large_file_read" "very_large_json_read" "$PROJECT_ROOT/tests/file/very_large_file_read/json_read_bun.js" "$PROJECT_ROOT/tests/file/very_large_file_read/json_read_node.js"

echo "Large file read tests completed."

echo "Read tests completed."

echo "Starting write tests..."

run_file_benchmark "write_small_files" "write_small_files" "$PROJECT_ROOT/tests/file/write_small_files/write_small_files_bun.js" "$PROJECT_ROOT/tests/file/write_small_files/write_small_files_node.js"
run_file_benchmark "write_large_file" "write_large_file" "$PROJECT_ROOT/tests/file/write_large_file/write_large_file_bun.js" "$PROJECT_ROOT/tests/file/write_large_file/write_large_file_node.js"

echo "Write tests completed."
echo "All file tests completed. Results are saved in their respective directories under $RESULTS_DIR."