import path from 'path';

const testDataPath = process.env.TEST_DATA_PATH || '/app/test_data';
const filePath = path.join(testDataPath, 'large_data.json');

const file = Bun.file(filePath);

const data = await file.arrayBuffer();
const buffer = Buffer.from(data);

const compressed = Bun.gzipSync(buffer);
const decompressed = Bun.gunzipSync(compressed);