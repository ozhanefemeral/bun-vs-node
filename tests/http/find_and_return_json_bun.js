import { file } from 'bun';

const server = Bun.serve({
  port: 3002,
  async fetch(req) {
    const url = new URL(req.url);

    if (url.pathname.startsWith("/api/users/") && req.method === "GET") {
      try {
        const usersData = await file('users.json').json();
        const id = parseInt(url.pathname.split("/")[3]);
        const user = usersData.users.find(u => u.id === id);

        if (user) {
          return Response.json({
            status: "success",
            data: user,
            timestamp: new Date().toISOString()
          });
        } else {
          return Response.json({ error: "User not found" }, { status: 404 });
        }
      } catch (error) {
        return Response.json({ error: "Failed to read users data" }, { status: 500 });
      }
    } else {
      return Response.json({ error: "Not found" }, { status: 404 });
    }
  },
});

console.log(`Bun server (find user) listening on http://localhost:${server.port} ...`);