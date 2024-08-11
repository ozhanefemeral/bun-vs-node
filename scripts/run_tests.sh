#!/bin/bash

# Set the base directory
BASE_DIR="/app/scripts"

echo "Starting all benchmarks..."

echo "Running basic tests..."
$BASE_DIR/run_basic_tests.sh

echo "Running file tests..."
$BASE_DIR/run_file_tests.sh

echo "All tests completed. Results are saved in their respective directories under /app/results."