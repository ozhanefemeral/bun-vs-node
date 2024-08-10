import { readFileSync } from 'fs';
import { gzipSync, gunzipSync } from 'zlib';

const filePath = './large_data.json';
const buffer = readFileSync(filePath);

const compressed = gzipSync(buffer);
const decompressed = gunzipSync(compressed);