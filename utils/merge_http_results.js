import { readdir, readFile, writeFile } from 'fs/promises';
import { join, basename } from 'path';

const mergeJsonResults = async (directory) => {
  const files = await readdir(directory);
  const jsonFiles = files.filter(file => file.endsWith('bombardier.json'));

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

  await writeFile(join(directory, 'merged_results.json'), JSON.stringify(mergedData, null, 2));
  console.log(`Merged results saved to ${join(directory, 'merged_results.json')}`);
};

const processAllHttpTests = async () => {
  const httpResultsDir = '/app/results/http';
  const testDirs = await readdir(httpResultsDir);

  for (const dir of testDirs) {
    const fullPath = join(httpResultsDir, dir);
    await mergeJsonResults(fullPath);
  }
};

processAllHttpTests().catch(console.error);