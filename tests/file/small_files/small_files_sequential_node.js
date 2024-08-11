import fs from 'fs';
import path, { join } from 'path';

const testDataPath = process.env.TEST_DATA_PATH || '/app/test_data';
const directoryPath = join(testDataPath, 'small_files');

function processFilesSequentially() {
  const files = fs.readdirSync(directoryPath);
  let totalBalance = 0;
  let activeUsers = 0;
  let totalAge = 0;
  let totalProcessed = 0;

  for (const file of files) {
    const filePath = path.join(directoryPath, file);
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

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

console.time('Sequential Processing');
processFilesSequentially();
console.timeEnd('Sequential Processing');