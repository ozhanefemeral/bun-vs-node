import { file } from 'bun';

const server = Bun.serve({
  port: 3002,
  async fetch(req) {
    const url = new URL(req.url);
    if (url.pathname === '/') {
      try {
        const content = await file('index.html').text();
        return new Response(content, {
          headers: { 'Content-Type': 'text/html' },
        });
      } catch (error) {
        return new Response('Internal Server Error', { status: 500 });
      }
    } else {
      return new Response('Not Found', { status: 404 });
    }
  },
});

console.log(`Listening on http://localhost:${server.port} ...`);