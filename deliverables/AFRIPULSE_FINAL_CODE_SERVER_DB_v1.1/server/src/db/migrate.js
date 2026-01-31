const fs = require("fs");
const path = require("path");
const { query, getPool } = require("./client");

async function run() {
  const pool = getPool();

  // Check if we're using mock database
  if (pool.constructor.name === "MockPool") {
    console.log("[migrate] Using mock database - migrations not needed");
    await pool.end();
    console.log("[migrate] done");
    return;
  }

  const dir = path.join(__dirname, "migrations");
  const files = fs
    .readdirSync(dir)
    .filter((f) => f.endsWith(".sql"))
    .sort();
  for (const f of files) {
    const sql = fs.readFileSync(path.join(dir, f), "utf8");
    console.log("[migrate]", f);
    await query(sql);
  }
  await getPool().end();
  console.log("[migrate] done");
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
