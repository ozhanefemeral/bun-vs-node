import fs from 'fs';
import path from 'path';
import { promisify } from 'util';

const readdir = promisify(fs.readdir);
const readFile = promisify(fs.readFile);

const directoryPath = '../../../test_data/small_files';

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

  console.log(`Processed ${totalProcessed} items from ${files.length} files`);
  console.log(`Average Balance: $${averageBalance.toFixed(2)}`);
  console.log(`Active Users: ${activeUsers}`);
  console.log(`Average Age: ${averageAge.toFixed(2)}`);
}

console.time('Parallel Processing');
processFilesParallel().then(() => console.timeEnd('Parallel Processing'));