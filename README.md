# Node.js vs Bun Performance Benchmark

Node.js and Bun performance comparison across various programming tasks.

## Tools & Versions

- Node.js: 20.16.0
- Bun: 1.1.20
- Docker: 20.10.8
- Hyperfine: 1.16.1
- Bombardier: 1.4.0
- Go: 1.19.4

## Project Structure

- `Dockerfile.both`: Docker configuration for both Bun and Node.js environments
- `tests/`: Directory containing test scripts for various categories
  - `basic/`: Basic operation tests (e.g., while loops, Fibonacci calculation)
  - `file/`: File operation tests
  - `http/`: HTTP server tests
  - `package_install/`: Package manager performance tests
- `scripts/`: Scripts to run benchmarks
  - `local/`: Scripts for running tests on local machine
  - Root level scripts: For running tests in Docker containers
- `utils/`: Utility scripts for generating test data

## Running Benchmarks

### Prerequisites

Before running the benchmarks, you need to build the Docker image from Dockerfile.both:

To run the benchmarks, use the following commands:

```bash
bun run benchmark # Run all benchmarks on Docker
bun run benchmark:local # Run all benchmarks on local machine
bun run benchmark-basic
bun run benchmark-basic:local
# and so on... Check package.json for more commands
```

# Build the Docker images

Building only the `Dockerfile.both` is enough for running the tests on Docker. Other Dockerfiles are there just for reference.

```bash
docker build -f Dockerfile.both -t benchmark-test .
```

# Run the tests

Feel free to change the CPU and memory values, or use different images

```bash
docker run --cpus=6 --memory=12g --rm -v $(pwd):/app benchmark-test bash /app/run_tests.sh
# or use benchmark command, but keep in mind that will use the default values for CPU and memory
bun run benchmark
```

## Benchmarking Tools

This project uses [Hyperfine](https://github.com/sharkdp/hyperfine) for benchmarking, which is also installed in the Docker containers. For local bechmarks, you have to install it yourself. Same for Bombardier; which also requires Go to be installed.

## Results

Benchmark results are saved as Markdown and JSON files in the results/ directory, organized by test category. Resource usage data is saved as text files in the same location.

## Notes

I am running the benchmarks on a Digital Ocean Droplet. It has 8GB of RAM and 4 dedicated CPUs. 50 GB of storage along with 2GBPs bandwidth.

HTTP Servers are also running on their own Droplets. They have 4GB of RAM and 2 dedicated CPUs. 25 GB of storage along with 2GBPs bandwidth.

All droplets are located in Frankfurt and has Ubuntu 24.4 LTS.

I have $200 credits in my Digital Ocean account thanks to Github Student Pack. It will eventually run out and I have to shut down the droplets.
