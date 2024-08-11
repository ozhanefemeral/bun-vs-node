import fs from 'fs/promises';
import path from 'path';

const numberOfFiles = 10000;
const itemsPerFile = 5;
const outputDir = '/app/test_data/write_small_files';

function generateRandomItem() {
  return {
    id: Math.random().toString(36).substr(2, 9),
    name: `Person ${Math.floor(Math.random() * 1000)}`,
    age: Math.floor(Math.random() * 80) + 18,
    balance: `$${(Math.random() * 10000).toFixed(2)}`,
    isActive: Math.random() > 0.5,
    registered: new Date(Date.now() - Math.random() * 315569260000).toISOString()
  };
}

async function writeSmallFile(fileIndex) {
  const items = Array.from({ length: itemsPerFile }, generateRandomItem);
  const fileName = `data_${fileIndex.toString().padStart(4, '0')}.json`;
  const filePath = path.join(outputDir, fileName);
  await fs.writeFile(filePath, JSON.stringify(items, null, 2));
}

console.time('Small Files Write');
Promise.all(
  Array.from({ length: numberOfFiles }, (_, i) => writeSmallFile(i))
).then(() => {
  console.timeEnd('Small Files Write');
  console.log(`Written ${numberOfFiles} small JSON files in ${outputDir}`);
});