import { serve } from "bun";
import { and, eq, like, sql } from "drizzle-orm";
import { movies, userFavorites, users } from "./schema";
import { db } from "./db";

const server = serve({
  port: 6693,
  async fetch(req) {
    try {
      const url = new URL(req.url);

      if (url.pathname === "/" || url.pathname === "/index.html") {
        const file = Bun.file("index.html");
        if (await file.exists()) {
          return new Response(file, {
            headers: { "Content-Type": "text/html" },
          });
        } else {
          return new Response("File not found", { status: 404 });
        }
      }

      // Serve static files (for images)
      if (url.pathname.endsWith(".jpg")) {
        const file = Bun.file(url.pathname.slice(1)); // Remove leading '/'
        if (await file.exists()) {
          return new Response(file, {
            headers: { "Content-Type": "image/jpg" },
          });
        } else {
          return new Response("Image not found", { status: 404 });
        }
      }

      if (url.pathname.startsWith("/api")) {
        if (req.method === "GET") {
          const params = url.searchParams;

          if (url.pathname === "/api/movies") {
            const title = params.get("title");
            const description = params.get("description");
            const genre = params.get("genre") as
              | "action"
              | "comedy"
              | "drama"
              | "sci-fi"
              | "adventure"
              | "horror"
              
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

            const results = await db
              .select()
              .from(movies)
              .where(and(...conditions));

            return Response.json(results);
          }

          if (url.pathname === "/api/user") {
            const userId = params.get("id");
            if (!userId) {
              return new Response("User ID is required", { status: 400 });
            }

            const user = await db
              .select()
              .from(users)
              .where(eq(users.id, parseInt(userId)))
              .get();

            if (!user) {
              return new Response("User not found", { status: 404 });
            }

            const favorites = await db
              .select({
                movie: movies,
              })
              .from(userFavorites)
              .innerJoin(movies, eq(userFavorites.movieId, movies.id))
              .where(eq(userFavorites.userId, parseInt(userId)));

            return Response.json({
              user,
              favorites: favorites.map((f) => f.movie),
            });
          }
        }

        if (req.method === "POST" && url.pathname === "/api/movies") {
          const body = await req.json();
          const { title, description, genre, date } = body;

          if (!title || !genre) {
            return new Response("Title and genre are required", { status: 400 });
          }

          try {
            const result = await db
              .insert(movies)
              .values({ title, description, genre, date })
              .returning({ insertedId: movies.id });

            if (result.length > 0) {
              return Response.json({ id: result[0].insertedId }, { status: 201 });
            } else {
              throw new Error("Insert operation did not return an ID");
            }
          } catch (error) {
            console.error("Error inserting movie:", error);
            return new Response("Error creating movie", { status: 500 });
          }
        }
      }

      return new Response("Not Found", { status: 404 });
    } catch (error) {
      console.error("Unhandled server error:", error);
      return new Response("Internal Server Error", { status: 500 });
    }
  },
});

console.log(`Server running at http://localhost:${server.port}`);