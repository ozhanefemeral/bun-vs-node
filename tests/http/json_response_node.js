import { createServer } from 'http';

const server = createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ message: "Hello World!" }));
});

server.listen(3001, () => {
  console.log('Listening on http://localhost:3001 ...');
});