const { Pool } = require("pg");

let pool;
function getPool() {
  if (!pool) {
    const cs = process.env.DATABASE_URL;
    if (!cs || cs === "mock") {
      console.log("[DB] Using mock database (no PostgreSQL connection)");
      const mockClient = require("./mock-client");
      return mockClient.getPool();
    }
    try {
      pool = new Pool({ connectionString: cs });
      console.log("[DB] Connected to PostgreSQL");
    } catch (error) {
      console.log(
        "[DB] Failed to connect to PostgreSQL, falling back to mock database",
      );
      const mockClient = require("./mock-client");
      return mockClient.getPool();
    }
  }
  return pool;
}

async function query(text, params) {
  const p = getPool();
  return await p.query(text, params);
}

module.exports = { getPool, query };
