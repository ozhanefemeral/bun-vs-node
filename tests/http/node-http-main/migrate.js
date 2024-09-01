import { migrate } from "drizzle-orm/better-sqlite3/migrator";
import { drizzle } from "drizzle-orm/better-sqlite3";
import Database from 'better-sqlite3';

const sqlite = new Database("sqlite.db");
const db = drizzle(sqlite);

async function runMigrations() {
  try {
    await migrate(db, { migrationsFolder: "./drizzle" });
    console.log("Migrations completed successfully");
  } catch (error) {
    console.error("Error running migrations:", error);
  } finally {
    sqlite.close();
  }
}

runMigrations();