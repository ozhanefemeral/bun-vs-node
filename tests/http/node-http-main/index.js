import { createServer } from 'http';
import { promises as fs } from 'fs';
import { join } from 'path';
import { and, eq, like, sql } from "drizzle-orm";
import { db } from "./db.js"

import { movies, userFavorites, users } from "./schema.js";

const server = createServer(async (req, res) => {
  try {
    const url = new URL(req.url, `http://${req.headers.host}`);

    if (url.pathname === "/" || url.pathname === "/index.html") {
      try {
        const content = await fs.readFile('index.html', 'utf-8');
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(content);
      } catch (error) {
        console.error("Error reading index.html:", error);
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('File Not Found');
      }
      return;
    }

    // Serve static files (for images)
    if (url.pathname.endsWith(".jpg")) {
      try {
        const content = await fs.readFile(join(__dirname, url.pathname.slice(1)));
        res.writeHead(200, { 'Content-Type': 'image/jpeg' });
        res.end(content);
      } catch (error) {
        console.error("Error reading image:", error);
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('Image not found');
      }
      return;
    }

    if (url.pathname.startsWith("/api")) {
      if (req.method === "GET") {
        const params = url.searchParams;

        if (url.pathname === "/api/movies") {
          const title = params.get("title");
          const description = params.get("description");
          const genre = params.get("genre");

          let conditions = [];

          if (title) {
            conditions.push(like(movies.title, `%${title}%`));
          }
          if (description) {
            conditions.push(like(movies.description, `%${description}%`));
          }
          if (genre) {
            conditions.push(eq(movies.genre, genre));
          }

          try {
            const limit = parseInt(params.get("limit")) || 20;
            const page = parseInt(params.get("page")) || 1;
            const offset = (page - 1) * limit;

            const results = await db
              .select()
              .from(movies)
              .where(and(...conditions))
              .limit(limit)
              .offset(offset);

            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(results));
          } catch (error) {
            console.error("Error querying movies:", error);
            res.writeHead(500, { 'Content-Type': 'text/plain' });
            res.end('Internal Server Error');
          }
          return;
        }
        if (url.pathname === "/api/user") {
          const userId = params.get("id");
          if (!userId) {
            res.writeHead(400, { 'Content-Type': 'text/plain' });
            res.end('User ID is required');
            return;
          }

          try {
            const user = await db
              .select()
              .from(users)
              .where(eq(users.id, parseInt(userId)))
              .get();

            if (!user) {
              res.writeHead(404, { 'Content-Type': 'text/plain' });
              res.end('User not found');
              return;
            }

            const favorites = await db
              .select({
                movie: movies,
              })
              .from(userFavorites)
              .innerJoin(movies, eq(userFavorites.movieId, movies.id))
              .where(eq(userFavorites.userId, parseInt(userId)));

            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
              user,
              favorites: favorites.map((f) => f.movie),
            }));
          } catch (error) {
            console.error("Error fetching user data:", error);
            res.writeHead(500, { 'Content-Type': 'text/plain' });
            res.end('Internal Server Error');
          }
          return;
        }
      }
      if (req.method === "POST" && url.pathname === "/api/movies") {
        let body = '';
        req.on('data', chunk => {
          body += chunk.toString();
        });
        req.on('end', async () => {
          try {
            const { title, description, genre, date } = JSON.parse(body);

            if (!title || !genre) {
              res.writeHead(400, { 'Content-Type': 'text/plain' });
              res.end('Title and genre are required');
              return;
            }

            const result = await db
              .insert(movies)
              .values({ title, description, genre, date })
              .returning({ insertedId: movies.id });

            if (result.length > 0) {
              res.writeHead(201, { 'Content-Type': 'application/json' });
              res.end(JSON.stringify({ id: result[0].insertedId }));
            } else {
              throw new Error("Insert operation did not return an ID");
            }
          } catch (error) {
            console.error("Error inserting movie:", error);
            res.writeHead(500, { 'Content-Type': 'text/plain' });
            res.end('Error creating movie');
          }
        });
        return;
      }
    }
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not Found');
  } catch (error) {
    console.error("Unhandled server error:", error);
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end('Internal Server Error');
  }
});

const PORT = 6693;
server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});