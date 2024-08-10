#!/bin/bash

run_test() {
    local runtime=$1
    local script=$2
    echo "Running $script with $runtime"
    
    # Run Hyperfine benchmark
    hyperfine \
        --warmup 3 \
        --min-runs 100 \
        --export-markdown /app/tests/basic/${runtime}_${script%.js}_results.md \
        --export-json /app/tests/basic/${runtime}_${script%.js}_results.json \
        --show-output \
        --ignore-failure \
        "$runtime /app/tests/basic/$script"
    
    # Run with time command for resource usage
    echo "Resource usage for $script with $runtime:"
    /usr/bin/time -p $runtime /app/tests/basic/$script 2>&1 | tee /app/tests/basic/${runtime}_${script%.js}_resources.txt
    echo ""
}

# Determine which runtime to use based on what's available
if command -v bun &> /dev/null
then
    RUNTIME="bun"
elif command -v node &> /dev/null
then
    RUNTIME="node"
else
    echo "Neither Bun nor Node.js found. Exiting."
    exit 1
fi

echo "Using runtime: $RUNTIME"

# Run tests for the detected runtime
run_test "$RUNTIME" "while_loop.js"
run_test "$RUNTIME" "fibonacci.js"