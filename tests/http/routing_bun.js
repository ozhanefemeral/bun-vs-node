const server = Bun.serve({
  port: 3002,
  fetch(req) {
    const url = new URL(req.url);
    switch (url.pathname) {
      case '/':
        return new Response("Home");
      case '/about':
        return new Response("About");
      default:
        return new Response("Not Found", { status: 404 });
    }
  },
});

console.log(`Listening on http://localhost:${server.port} ...`);