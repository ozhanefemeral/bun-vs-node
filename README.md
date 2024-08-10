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

To run the benchmarks, use the following commands:

```bash
docker build -f Dockerfile.bun -t bun-test .
docker build -f Dockerfile.node -t node-test .
docker run --cpus=1 --memory=1g --rm -v $(pwd):/app bun-test bash /app/run_tests.sh
docker run --cpus=1 --memory=1g --rm -v $(pwd):/app node-test bash /app/run_tests.sh
```

These commands are also stored in `commands.txt`. Bulding the Dockerfiles before running tests is necessary.

## Benchmarking Tool

This project uses [Hyperfine](https://github.com/sharkdp/hyperfine) for benchmarking, which is installed in the Docker containers.

## Results

Benchmark results are saved as Markdown files in the `tests/basic/` directory. Resource usage data is saved as text files in the same location.