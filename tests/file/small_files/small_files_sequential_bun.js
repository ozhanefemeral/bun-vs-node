import { readdir } from 'node:fs/promises';
import { join } from 'node:path';

const testDataPath = process.env.TEST_DATA_PATH || '/app/test_data';
const directoryPath = join(testDataPath, 'small_files');

async function processFilesSequentially() {
    const files = await readdir(directoryPath);
    let totalBalance = 0;
    let activeUsers = 0;
    let totalAge = 0;

    for (const file of files) {
        const filePath = join(directoryPath, file);

        const data = await Bun.file(filePath).json();

        for (const item of data) {
            totalBalance += parseFloat(item.balance.replace('$', '').replace(',', ''));
            if (item.isActive) activeUsers++;
            totalAge += item.age;
        }
    }

    const totalUsers = files.length * 5; // Assuming each file has 5 items
    console.log(`Average Balance: $${(totalBalance / totalUsers).toFixed(2)}`);
    console.log(`Active Users: ${activeUsers}`);
    console.log(`Average Age: ${(totalAge / totalUsers).toFixed(2)}`);
}

console.time('Sequential Processing');
await processFilesSequentially();
console.timeEnd('Sequential Processing');