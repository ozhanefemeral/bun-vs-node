const filePath = '/app/test_data/very_large_data.csv';

async function readLargeCSV() {
  const file = Bun.file(filePath);
  const text = await file.text();
  const lines = text.split('\n');
  console.log(`Total lines: ${lines.length}`);
}

console.time('Bun CSV Read');
await readLargeCSV();
console.timeEnd('Bun CSV Read');