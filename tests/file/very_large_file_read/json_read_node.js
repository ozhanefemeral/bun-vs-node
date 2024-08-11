import { createReadStream } from 'fs';
import { createInterface } from 'readline';

const filePath = '/app/test_data/large_data.json';

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