import { writeFileSync, createWriteStream } from 'node:fs';
import { join } from 'node:path';

const outputDir = '/app/test_data';

function getRandomName() {
  const names = ['John', 'Jane', 'Bob', 'Alice', 'Charlie', 'David', 'Eva', 'Frank', 'Grace', 'Henry'];
  return names[Math.floor(Math.random() * names.length)];
}

function generateObject(index) {
  return {
    id: index,
    name: `${getRandomName()} ${getRandomName()}`,
    age: Math.floor(Math.random() * 50) + 20,
    email: `${getRandomName().toLowerCase()}@example.com`,
    balance: (Math.random() * 10000).toFixed(2)
  };
}

function generateLargeCSV(fileName, size) {
  const filePath = join(outputDir, fileName);
  const writeStream = createWriteStream(filePath);

  writeStream.write('id,name,age,email,balance\n');

  let i = 0;
  while (writeStream.bytesWritten < size) {
    const obj = generateObject(i);
    writeStream.write(`${obj.id},${obj.name},${obj.age},${obj.email},${obj.balance}\n`);
    i++;

    if (i % 100000 === 0) {
      console.log(`Generated ${i} rows, ${writeStream.bytesWritten} bytes`);
    }
  }

  writeStream.end();
  console.log(`Finished generating CSV file: ${filePath}`);
}

function generateLargeJSON(fileName, size) {
  const filePath = join(outputDir, fileName);
  const writeStream = createWriteStream(filePath);

  writeStream.write('[\n');

  let i = 0;
  let isFirst = true;
  while (writeStream.bytesWritten < size) {
    const obj = generateObject(i);
    if (!isFirst) {
      writeStream.write(',\n');
    }
    writeStream.write(JSON.stringify(obj));
    isFirst = false;
    i++;

    if (i % 100000 === 0) {
      console.log(`Generated ${i} objects, ${writeStream.bytesWritten} bytes`);
    }
  }

  writeStream.write('\n]');
  writeStream.end();
  console.log(`Finished generating JSON file: ${filePath}`);
}

// Generate 1GB CSV and JSON files
const oneGB = 1 * 1024 * 1024 * 1024; // 1GB in bytes

console.time('Generate Very Large CSV');
generateLargeCSV('very_large_data.csv', oneGB);
console.timeEnd('Generate Very Large CSV');

console.time('Generate Very  Large JSON');
generateLargeJSON('very_large_data.json', oneGB);
console.timeEnd('Generate Very Large JSON');