#!/bin/bash

# Set the base directory
BASE_DIR="/app/scripts"

chmod +x $BASE_DIR/*.sh

echo "Starting all benchmarks..."

echo "Running basic tests..."
$BASE_DIR/run_basic_tests.sh

echo "Running file tests..."
$BASE_DIR/run_file_tests.sh

echo "Running HTTP tests..."
$BASE_DIR/run_http_tests.sh

echo "Running package manager tests..."
$BASE_DIR/run_package_manager_tests.sh

echo "All tests completed. Results are saved in their respective directories under /app/results."