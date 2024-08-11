import { readFileSync } from 'fs';
import { gzipSync, gunzipSync } from 'zlib';
import path from 'path';

const testDataPath = process.env.TEST_DATA_PATH || '/app/test_data';
const filePath = path.join(testDataPath, 'large_data.json');

const buffer = readFileSync(filePath);

const compressed = gzipSync(buffer);
const decompressed = gunzipSync(compressed);