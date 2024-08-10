# Node.js vs Bun Performance Benchmark

## Goal

This project aims to compare the performance of Node.js and Bun runtimes across various common programming tasks. By running identical scenarios on both runtimes, we can gain insights into their relative strengths and weaknesses. 

## Project Structure

- `Dockerfile.bun`: Docker configuration for Bun environment
- `Dockerfile.node`: Docker configuration for Node.js environment
- `tests/basic/`: Directory containing test scripts
  - `while_loop.js`: Simple while loop test
  - `fibonacci.js`: Recursive Fibonacci calculation test
- `run_tests.sh`: Script to run benchmarks in Docker containers
- `hyperfine-commands.txt`: File storing useful Hyperfine commands

## Running Benchmarks

### Prerequisites

You should run generate_large_json.js to create a large JSON file for the tests. This file is not included in the repository due to its size. 

```bash
node generate_large_json.js
# or
bun generate_large_json.js
```

To run the benchmarks, use the following commands:

```bash
# Build the Docker images

# Building only the last image is enough for running the tests

docker build -f Dockerfile.bun -t bun-test .
docker build -f Dockerfile.node -t node-test .
docker build -f Dockerfile.both -t benchmark-test .

# Run the tests

# Feel free to change the CPU and memory values, or use different images
docker run --cpus=6 --memory=12g --rm -v $(pwd):/app benchmark-test bash /app/run_tests.sh
```

Or you can adjust the cpu and the memory allocated to the Docker.

```
docker run \
  --cpus=6 \
  --memory=24g \
  --rm \
  -v $(pwd):/app \
  benchmark-test \
  bash /app/run_tests.sh`
```

These commands are also stored in `commands.txt`. Bulding the Dockerfiles before running tests is necessary.

## Benchmarking Tool

This project uses [Hyperfine](https://github.com/sharkdp/hyperfine) for benchmarking, which is installed in the Docker containers.

## Results

Benchmark results are saved as Markdown files in the `tests/basic/` directory. Resource usage data is saved as text files in the same location.