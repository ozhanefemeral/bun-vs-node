import { createServer } from 'http';
import { readFile } from 'fs/promises';

const server = createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  if (url.pathname === "/api/users" && req.method === "GET") {
    try {
      const usersData = JSON.parse(await readFile('users.json', 'utf8'));
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        status: "success",
        data: usersData,
        timestamp: new Date().toISOString(),
        count: usersData.users.length
      }));
    } catch (error) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: "Failed to read users data" }));
    }
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: "Not found" }));
  }
});

const PORT = 3003;
server.listen(PORT, () => {
  console.log(`Node.js server (whole JSON) listening on http://localhost:${PORT} ...`);
});