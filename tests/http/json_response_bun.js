const server = Bun.serve({
  port: 3001,
  fetch(req) {
    return Response.json({ message: "Hello World!" });
  },
});

console.log(`Listening on http://localhost:${server.port} ...`);