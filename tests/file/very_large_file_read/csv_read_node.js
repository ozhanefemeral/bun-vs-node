import { createReadStream } from 'fs';
import { createInterface } from 'readline';

const filePath = '/app/test_data/large_data.csv';

async function readLargeCSV() {
  const fileStream = createReadStream(filePath);
  const rl = createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  let lineCount = 0;
  for await (const line of rl) {
    lineCount++;
  }

  console.log(`Total lines: ${lineCount}`);
}

console.time('Node.js CSV Read');
readLargeCSV().then(() => {
  console.timeEnd('Node.js CSV Read');
});