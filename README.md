# Node.js vs Bun Performance Benchmark

## Goal

This project aims to compare the performance of Node.js and Bun runtimes across various common programming tasks. By running identical scenarios on both runtimes, we can gain insights into their relative strengths and weaknesses.

## Test Scenarios

Our benchmarks cover three main categories:

1. **Simple Tasks**

   - Execute a simple loop 1 million times
   - Execute a function that performs string operations 1 million times
   - Execute a function with heavy recursion

2. **Mathematical Operations**

   - Calculate π to 1 million digits
   - Sort 1 million random numbers
   - Perform matrix multiplication on large matrices

3. **File I/O Operations**
   - Read/Write operations on large files (1GB)
   - Read/Write operations on multiple small files
   - Directory operations (reading, writing, deleting)

Each scenario is run 100 times for both Node.js and Bun to ensure statistical significance.
