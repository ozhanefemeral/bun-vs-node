import { join } from 'path';

const testDataPath = process.env.TEST_DATA_PATH || '/app/test_data';
const directoryPath = join(testDataPath, 'very_large_files');
const filePath = join(directoryPath, 'very_large_data.json');

async function readLargeJSON() {
  const file = Bun.file(filePath);
  const json = await file.json();
  console.log(`Total objects: ${json.length}`);
}

console.time('Bun JSON Read');
await readLargeJSON();
console.timeEnd('Bun JSON Read');