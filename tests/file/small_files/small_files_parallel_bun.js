import { readdir } from 'fs/promises';
import { join } from 'path';

const testDataPath = process.env.TEST_DATA_PATH || '/app/test_data';
const directoryPath = join(testDataPath, 'small_files');

async function processFilesParallel() {
  const files = await readdir(directoryPath);
  const fileContents = await Promise.all(
    files.map(file => Bun.file(join(directoryPath, file)).json())
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