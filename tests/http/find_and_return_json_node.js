import { createServer } from 'http';
import { readFile } from 'fs/promises';

const server = createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  if (url.pathname.startsWith("/api/users/") && req.method === "GET") {
    try {
      const usersData = JSON.parse(await readFile('users.json', 'utf8'));
      const id = parseInt(url.pathname.split("/")[3]);
      const user = usersData.users.find(u => u.id === id);

      if (user) {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          status: "success",
          data: user,
          timestamp: new Date().toISOString()
        }));
      } else {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: "User not found" }));
      }
    } catch (error) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: "Failed to read users data" }));
    }
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: "Not found" }));
  }
});

const PORT = 3004;
server.listen(PORT, () => {
  console.log(`Node.js server (find user) listening on http://localhost:${PORT} ...`);
});