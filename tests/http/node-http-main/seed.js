import Database from 'better-sqlite3';
import { faker } from "@faker-js/faker";
import fs from 'fs';

const DB_FILE = 'sqlite.db';

// Delete existing database file if it exists
if (fs.existsSync(DB_FILE)) {
  fs.unlinkSync(DB_FILE);
}

const db = new Database(DB_FILE);

const randomInt = (min, max) =>
  Math.floor(Math.random() * (max - min + 1)) + min;

// Generate and insert users
const generateAndInsertUsers = (count, insertUser) => {
  for (let i = 0; i < count; i++) {
    insertUser.run({
      id: i + 1,
      name: faker.person.fullName(),
    });
  }
};

// Generate and insert movies
const generateAndInsertMovies = (count, insertMovie) => {
  const genres = ["action", "comedy", "drama", "sci-fi", "adventure", "horror"];
  for (let i = 0; i < count; i++) {
    insertMovie.run({
      id: i + 1,
      title: faker.lorem.words(randomInt(1, 5)),
      description: faker.lorem.sentence(),
      genre: faker.helpers.arrayElement(genres),
      date: faker.date.past().getTime(),
    });
  }
};

// Generate and insert user favorites
const generateAndInsertUserFavorites = (userCount, movieCount, insertUserFavorite) => {
  for (let userId = 1; userId <= userCount; userId++) {
    const favoriteCount = randomInt(1, 10);
    const favorites = new Set();
    while (favorites.size < favoriteCount) {
      favorites.add(randomInt(1, movieCount));
    }
    for (const movieId of favorites) {
      insertUserFavorite.run({
        userId: userId,
        movieId: movieId,
      });
    }
  }
};

// Main seeding function
const seedDatabase = () => {
  console.time("Seeding database");

  const userCount = 1_000_000;
  const movieCount = 1_000_000;

  // Create tables
  db.exec(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
  )`);

  db.exec(`CREATE TABLE IF NOT EXISTS movies (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    genre TEXT NOT NULL CHECK(genre IN ('action', 'comedy', 'drama', 'sci-fi', 'adventure', 'horror')),
    date INTEGER NOT NULL
  )`);

  db.exec(`CREATE TABLE IF NOT EXISTS user_favorites (
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    PRIMARY KEY (user_id, movie_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (movie_id) REFERENCES movies(id)
  )`);

  console.log("Inserting users...");
  const insertUser = db.prepare(
    "INSERT INTO users (id, name) VALUES (@id, @name)"
  );
  db.transaction(() => {
    generateAndInsertUsers(userCount, insertUser);
  })();

  console.log("Inserting movies...");
  const insertMovie = db.prepare(
    "INSERT INTO movies (id, title, description, genre, date) VALUES (@id, @title, @description, @genre, @date)"
  );
  db.transaction(() => {
    generateAndInsertMovies(movieCount, insertMovie);
  })();

  console.log("Inserting user favorites...");
  const insertUserFavorite = db.prepare(
    "INSERT INTO user_favorites (user_id, movie_id) VALUES (@userId, @movieId)"
  );
  db.transaction(() => {
    generateAndInsertUserFavorites(userCount, movieCount, insertUserFavorite);
  })();

  console.log("Seeding completed");
  console.timeEnd("Seeding database");

  db.close();
};

seedDatabase();