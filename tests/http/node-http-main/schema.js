import {
  sqliteTable,
  text,
  integer,
  primaryKey,
} from "drizzle-orm/sqlite-core";

export const users = sqliteTable("users", {
  id: integer("id").primaryKey(),
  name: text("name").notNull(),
});

export const movies = sqliteTable("movies", {
  id: integer("id").primaryKey(),
  title: text("title").notNull(),
  description: text("description"),
  genre: text("genre", {
    enum: ["action", "comedy", "drama", "sci-fi", "adventure", "horror"],
  }).notNull(),
  date: integer("date").notNull(),
});

export const userFavorites = sqliteTable(
  "user_favorites",
  {
    userId: integer("user_id")
      .notNull()
      .references(() => users.id),
    movieId: integer("movie_id")
      .notNull()
      .references(() => movies.id),
  },
  (t) => ({
    pk: primaryKey({ columns: [t.userId, t.movieId] }),
  })
);
