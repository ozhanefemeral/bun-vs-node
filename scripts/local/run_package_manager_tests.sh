#!/bin/bash

BASE_DIR="$(pwd)"

run_package_install_benchmark() {
    local project=$1
    
    echo "Running benchmarks for $project"
    
    # Create results directory
    mkdir -p "$BASE_DIR/results/package_install/$project"
    
    # Prepare command for with lock files
    local prepare_with_lock="rm -rf $BASE_DIR/tests/package_install/$project/node_modules"
    
    # Prepare command for without lock files
    local prepare_without_lock="rm -rf $BASE_DIR/tests/package_install/$project/node_modules $BASE_DIR/tests/package_install/$project/bun.lockb $BASE_DIR/tests/package_install/$project/package-lock.json"
    
    # Run benchmark with lock files
    hyperfine \
        --warmup 2 \
        --min-runs 20 \
        --prepare "$prepare_with_lock" \
        --export-markdown "$BASE_DIR/results/package_install/local/$project/results_with_lock.md" \
        --export-json "$BASE_DIR/results/package_install/local/$project/results_with_lock.json" \
        --show-output \
        "cd $BASE_DIR/tests/package_install/$project && bun install" \
        "cd $BASE_DIR/tests/package_install/$project && npm install"
    
    # Run benchmark without lock files
    hyperfine \
        --warmup 2 \
        --min-runs 20 \
        --prepare "$prepare_without_lock" \
        --export-markdown "$BASE_DIR/results/package_install/local/$project/results_without_lock.md" \
        --export-json "$BASE_DIR/results/package_install/local/$project/results_without_lock.json" \
        --show-output \
        "cd $BASE_DIR/tests/package_install/$project && bun install" \
        "cd $BASE_DIR/tests/package_install/$project && npm install"
    
    echo "Resource usage for $project:"
    {
        echo "Bun with lock:"
        /usr/bin/time -v bash -c "$prepare_with_lock && cd $BASE_DIR/tests/package_install/$project && bun install" 2>&1
        echo -e "\nBun without lock:"
        /usr/bin/time -v bash -c "$prepare_without_lock && cd $BASE_DIR/tests/package_install/$project && bun install" 2>&1
        echo -e "\nNPM with lock:"
        /usr/bin/time -v bash -c "$prepare_with_lock && cd $BASE_DIR/tests/package_install/$project && npm install" 2>&1
        echo -e "\nNPM without lock:"
        /usr/bin/time -v bash -c "$prepare_without_lock && cd $BASE_DIR/tests/package_install/$project && npm install" 2>&1
    } | tee "$BASE_DIR/results/package_install/$project/resource_usage.txt"
}

run_single_package_install_benchmark() {
    echo "Running benchmark for bloated-project single package install"
    
    # Create results directory
    mkdir -p "$BASE_DIR/results/package_install/bloated-project"
    
    # Prepare command to remove the specific package before each run
    local prepare_command="rm -rf $BASE_DIR/tests/package_install/bloated-project/node_modules/moment"
    
    # Run benchmark
    hyperfine \
        --warmup 2 \
        --min-runs 20 \
        --prepare "$prepare_command" \
        --export-markdown "$BASE_DIR/results/package_install/local/bloated-project/results.md" \
        --export-json "$BASE_DIR/results/package_install/local/bloated-project/results.json" \
        --show-output \
        "cd $BASE_DIR/tests/package_install/bloated-project && bun add moment" \
        "cd $BASE_DIR/tests/package_install/bloated-project && npm install moment"
    
    echo "Resource usage for bloated-project single package install:"
    {
        echo "Bun:"
        /usr/bin/time -v bash -c "$prepare_command && cd $BASE_DIR/tests/package_install/bloated-project && bun add moment" 2>&1
        echo -e "\nNPM:"
        /usr/bin/time -v bash -c "$prepare_command && cd $BASE_DIR/tests/package_install/bloated-project && npm install moment" 2>&1
    } | tee "$BASE_DIR/results/package_install/bloated-project/resource_usage.txt"
}

projects=("nextjs" "svelte" "expo-react-native")

for project in "${projects[@]}"; do
    run_package_install_benchmark "$project"
done

run_single_package_install_benchmark

echo "All package installation benchmarks completed. Results are saved in their respective directories under $BASE_DIR/results/package_install."