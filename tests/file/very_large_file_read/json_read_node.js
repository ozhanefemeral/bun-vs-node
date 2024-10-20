import { createReadStream } from 'fs';
import { join } from 'path';
import { createInterface } from 'readline';

const testDataPath = process.env.TEST_DATA_PATH || '/app/test_data';
const directoryPath = join(testDataPath, 'very_large_files');
const filePath = join(directoryPath, 'very_large_data.json');

async function readLargeJSON() {
  const fileStream = createReadStream(filePath);
  const rl = createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  let objectCount = 0;
  let isFirstLine = true;

  for await (const line of rl) {
    if (isFirstLine || line === '[' || line === ']') {
      isFirstLine = false;
      continue;
    }

    const cleanedLine = line.endsWith(',') ? line.slice(0, -1) : line;
    JSON.parse(cleanedLine);
    objectCount++;
  }

  console.log(`Total objects: ${objectCount}`);
}

console.time('Node.js JSON Read');
readLargeJSON().then(() => {
  console.timeEnd('Node.js JSON Read');
});