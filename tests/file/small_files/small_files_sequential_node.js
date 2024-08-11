import fs from 'fs';
import path from 'path';

const directoryPath = '../../../test_data/small_files';

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

  console.log(`Processed ${totalProcessed} items from ${files.length} files`);
  console.log(`Average Balance: $${averageBalance.toFixed(2)}`);
  console.log(`Active Users: ${activeUsers}`);
  console.log(`Average Age: ${averageAge.toFixed(2)}`);
}

console.time('Sequential Processing');
processFilesSequentially();
console.timeEnd('Sequential Processing');