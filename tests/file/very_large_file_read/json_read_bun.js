const filePath = '/app/test_data/very_large_data.json';

async function readLargeJSON() {
  const file = Bun.file(filePath);
  const json = await file.json();
  console.log(`Total objects: ${json.length}`);
}

console.time('Bun JSON Read');
await readLargeJSON();
console.timeEnd('Bun JSON Read');