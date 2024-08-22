#!/bin/bash

# Set the base directory
BASE_DIR="/scripts/local"

chmod +x $BASE_DIR/*.sh

if ! command -v bun &> /dev/null || ! command -v node &> /dev/null; then
    echo "Both Bun and Node.js are required to run these tests. Exiting."
    exit 1
fi

echo "Starting all benchmarks..."

echo "Running basic tests..."
$BASE_DIR/run_basic_tests.sh

echo "Running file tests..."
$BASE_DIR/run_file_tests.sh

echo "Running HTTP tests..."
$BASE_DIR/run_http_tests.sh

echo "Running package manager tests..."
$BASE_DIR/local/run_package_manager_tests.sh
# You can run the following command to run package manager tests on Docker. Make sure you uncomment the line below and comment the line above.
# $BASE_DIR/run_package_manager_tests.sh

echo "All tests completed. Results are saved in their respective directories under /app/results."