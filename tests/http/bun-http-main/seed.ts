import { Database, Statement, type SQLQueryBindings } from "bun:sqlite";
import { faker } from "@faker-js/faker";

const db = new Database("sqlite.db");

// delete sqlite.db
db.exec(`DROP TABLE IF EXISTS users`);
db.exec(`DROP TABLE IF EXISTS movies`);
db.exec(`DROP TABLE IF EXISTS user_favorites`);

const randomInt = (min: number, max: number) =>
  Math.floor(Math.random() * (max - min + 1)) + min;

// Generate and insert users
const generateAndInsertUsers = (
  count: number,
  insertUser: Statement<unknown, SQLQueryBindings[]>
) => {
  for (let i = 0; i < count; i++) {
    insertUser.run({
      $id: i + 1,
      $name: faker.person.fullName(),
    });
  }
};

// Generate and insert movies
const generateAndInsertMovies = (
  count: number,
  insertMovie: Statement<unknown, SQLQueryBindings[]>
) => {
  const genres = ["action", "comedy", "drama", "sci-fi", "adventure", "horror"];
  for (let i = 0; i < count; i++) {
    insertMovie.run({
      $id: i + 1,
      $title: faker.lorem.words(randomInt(1, 5)),
      $description: faker.lorem.sentence(),
      $genre: faker.helpers.arrayElement(genres),
      $date: faker.date.past().getTime(),
    });
  }
};

// Generate and insert user favorites
const generateAndInsertUserFavorites = (
  userCount: number,
  movieCount: number,
  insertUserFavorite: any
) => {
  for (let userId = 1; userId <= userCount; userId++) {
    const favoriteCount = randomInt(1, 10);
    const favorites = new Set();
    while (favorites.size < favoriteCount) {
      favorites.add(randomInt(1, movieCount));
    }
    for (const movieId of favorites) {
      insertUserFavorite.run({
        $userId: userId,
        $movieId: movieId,
      });
    }
  }
};

// Main seeding function
const seedDatabase = async () => {
  console.time("Seeding database");

  const userCount = 1_000_000;
  const movieCount = 1_000_000;

  // Create tables
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS movies (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    genre TEXT NOT NULL CHECK(genre IN ('action', 'comedy', 'drama', 'sci-fi', 'adventure', 'horror')),
    date INTEGER NOT NULL
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS user_favorites (
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    PRIMARY KEY (user_id, movie_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (movie_id) REFERENCES movies(id)
  )`);

  console.log("Inserting users...");
  const insertUser = db.prepare(
    "INSERT INTO users (id, name) VALUES ($id, $name)"
  );
  db.transaction(() => {
    generateAndInsertUsers(userCount, insertUser);
  })();

  console.log("Inserting movies...");
  const insertMovie = db.prepare(
    "INSERT INTO movies (id, title, description, genre, date) VALUES ($id, $title, $description, $genre, $date)"
  );
  db.transaction(() => {
    generateAndInsertMovies(movieCount, insertMovie);
  })();

  console.log("Inserting user favorites...");
  const insertUserFavorite = db.prepare(
    "INSERT INTO user_favorites (user_id, movie_id) VALUES ($userId, $movieId)"
  );
  db.transaction(() => {
    generateAndInsertUserFavorites(userCount, movieCount, insertUserFavorite);
  })();

  console.log("Seeding completed");
  console.timeEnd("Seeding database");
};

seedDatabase().catch(console.error);
