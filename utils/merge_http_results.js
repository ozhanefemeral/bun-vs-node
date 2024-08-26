import { readdir, readFile, writeFile } from 'fs/promises';
import { join, basename } from 'path';

const RESULTS_DIR = '/root/bun-vs-node/results/http';

const mergeJsonResults = async (directory) => {
  try {
    const files = await readdir(directory);
    const jsonFiles = files.filter(file => file.endsWith('_bombardier.json'));

    if (jsonFiles.length !== 2) {
      console.error(`Expected exactly 2 JSON files in the directory ${directory}`);
      return;
    }

    const results = [];

    for (const file of jsonFiles) {
      const filePath = join(directory, file);
      const content = await readFile(filePath, 'utf-8');
      const data = JSON.parse(content);
      results.push({
        name: basename(file, '_bombardier.json'),
        bytesRead: data.result.bytesRead,
        bytesWritten: data.result.bytesWritten,
        timeTakenSeconds: data.result.timeTakenSeconds,
        req2xx: data.result.req2xx,
        latencyMean: data.result.latency.mean,
        latencyMax: data.result.latency.max,
        rpsMax: data.result.rps.max
      });
    }

    const mergedData = {
      spec: JSON.parse(await readFile(join(directory, jsonFiles[0]), 'utf-8')).spec,
      results: results
    };

    const mergedFilePath = join(directory, `${basename(directory)}_results.json`);
    await writeFile(mergedFilePath, JSON.stringify(mergedData, null, 2));
    console.log(`Merged results saved to ${mergedFilePath}`);
  } catch (error) {
    console.error(`Error processing directory ${directory}:`, error);
  }
};

const processAllHttpTests = async () => {
  try {
    const testDirs = await readdir(RESULTS_DIR);

    for (const dir of testDirs) {
      const fullPath = join(RESULTS_DIR, dir);
      await mergeJsonResults(fullPath);
    }
  } catch (error) {
    console.error('Error processing HTTP tests:', error);
  }
};

processAllHttpTests().catch(console.error);