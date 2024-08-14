import { file } from 'bun';

const server = Bun.serve({
  port: 3001,
  async fetch(req) {
    const url = new URL(req.url);

    if (url.pathname === "/api/users" && req.method === "GET") {
      try {
        const usersData = await file('users.json').json();
        return Response.json({
          status: "success",
          data: usersData,
          timestamp: new Date().toISOString(),
          count: usersData.users.length
        });
      } catch (error) {
        return Response.json({ error: "Failed to read users data" }, { status: 500 });
      }
    } else {
      return Response.json({ error: "Not found" }, { status: 404 });
    }
  },
});

console.log(`Bun server (whole JSON) listening on http://localhost:${server.port} ...`);