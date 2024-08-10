import { readFileSync } from 'fs';
import { gzipSync, gunzipSync } from 'zlib';

const filePath = '/app/tests/file/large_data.json';
const buffer = readFileSync(filePath);

const compressed = gzipSync(buffer);
const decompressed = gunzipSync(compressed);