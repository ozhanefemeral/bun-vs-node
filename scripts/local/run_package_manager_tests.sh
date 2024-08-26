#!/bin/bash

PROJECT_ROOT="$(pwd)"
RESULTS_DIR="$PROJECT_ROOT/results/package_install"

mkdir -p "$RESULTS_DIR"

run_package_install_benchmark() {
    local project=$1
    
    echo "Running benchmarks for $project"
    
    mkdir -p "$RESULTS_DIR/$project"
    
    local prepare_with_lock="rm -rf $PROJECT_ROOT/tests/package_install/$project/node_modules"
    
    local prepare_without_lock="rm -rf $PROJECT_ROOT/tests/package_install/$project/node_modules $PROJECT_ROOT/tests/package_install/$project/bun.lockb $PROJECT_ROOT/tests/package_install/$project/package-lock.json"
    
    hyperfine \
        --warmup 2 \
        --min-runs 20 \
        --prepare "$prepare_with_lock" \
        --export-markdown "$RESULTS_DIR/$project/results_with_lock.md" \
        --export-json "$RESULTS_DIR/$project/results_with_lock.json" \
        --show-output \
        "cd $PROJECT_ROOT/tests/package_install/$project && bun install" \
        "cd $PROJECT_ROOT/tests/package_install/$project && npm install"
    
    hyperfine \
        --warmup 2 \
        --min-runs 20 \
        --prepare "$prepare_without_lock" \
        --export-markdown "$RESULTS_DIR/$project/results_without_lock.md" \
        --export-json "$RESULTS_DIR/$project/results_without_lock.json" \
        --show-output \
        "cd $PROJECT_ROOT/tests/package_install/$project && bun install" \
        "cd $PROJECT_ROOT/tests/package_install/$project && npm install"
    
    echo "Resource usage for $project:"
    {
        echo "Bun with lock:"
        /usr/bin/time -v bash -c "$prepare_with_lock && cd $PROJECT_ROOT/tests/package_install/$project && bun install" 2>&1
        echo -e "\nBun without lock:"
        /usr/bin/time -v bash -c "$prepare_without_lock && cd $PROJECT_ROOT/tests/package_install/$project && bun install" 2>&1
        echo -e "\nNPM with lock:"
        /usr/bin/time -v bash -c "$prepare_with_lock && cd $PROJECT_ROOT/tests/package_install/$project && npm install" 2>&1
        echo -e "\nNPM without lock:"
        /usr/bin/time -v bash -c "$prepare_without_lock && cd $PROJECT_ROOT/tests/package_install/$project && npm install" 2>&1
    } | tee "$RESULTS_DIR/$project/resource_usage.txt"
}

run_single_package_install_benchmark() {
    echo "Running benchmark for bloated-project single package install"
    
    mkdir -p "$RESULTS_DIR/bloated-project"
    
    local prepare_command="rm -rf $PROJECT_ROOT/tests/package_install/bloated-project/node_modules/moment"
    
    hyperfine \
        --warmup 2 \
        --min-runs 20 \
        --prepare "$prepare_command" \
        --export-markdown "$RESULTS_DIR/bloated-project/results.md" \
        --export-json "$RESULTS_DIR/bloated-project/results.json" \
        --show-output \
        "cd $PROJECT_ROOT/tests/package_install/bloated-project && bun add moment" \
        "cd $PROJECT_ROOT/tests/package_install/bloated-project && npm install moment"
    
    echo "Resource usage for bloated-project single package install:"
    {
        echo "Bun:"
        /usr/bin/time -v bash -c "$prepare_command && cd $PROJECT_ROOT/tests/package_install/bloated-project && bun add moment" 2>&1
        echo -e "\nNPM:"
        /usr/bin/time -v bash -c "$prepare_command && cd $PROJECT_ROOT/tests/package_install/bloated-project && npm install moment" 2>&1
    } | tee "$RESULTS_DIR/bloated-project/resource_usage.txt"
}

projects=("nextjs" "svelte" "expo-react-native")

for project in "${projects[@]}"; do
    run_package_install_benchmark "$project"
done

run_single_package_install_benchmark

echo "All package installation benchmarks completed. Results are saved in their respective directories under $RESULTS_DIR."