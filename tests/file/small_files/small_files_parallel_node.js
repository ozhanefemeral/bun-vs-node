import fs from 'fs';
import path, { join } from 'path';
import { promisify } from 'util';

const readdir = promisify(fs.readdir);
const readFile = promisify(fs.readFile);

const testDataPath = process.env.TEST_DATA_PATH || '/app/test_data';
const directoryPath = join(testDataPath, 'small_files');

async function processFilesParallel() {
  const files = await readdir(directoryPath);
  const fileContents = await Promise.all(
    files.map(file => readFile(path.join(directoryPath, file), 'utf8').then(JSON.parse))
  );

  let totalBalance = 0;
  let activeUsers = 0;
  let totalAge = 0;
  let totalProcessed = 0;

  for (const data of fileContents) {
    for (const item of data) {
      totalBalance += parseFloat(item.balance.replace('$', '').replace(',', ''));
      if (item.isActive) activeUsers++;
      totalAge += item.age;
      totalProcessed++;
    }
  }

  const averageBalance = totalBalance / totalProcessed;
  const averageAge = totalAge / totalProcessed;
}

console.time('Parallel Processing');
processFilesParallel().then(() => console.timeEnd('Parallel Processing'));