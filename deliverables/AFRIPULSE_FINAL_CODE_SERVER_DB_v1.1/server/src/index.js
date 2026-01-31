require("dotenv").config();
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");

const { healthRouter } = require("./routes/health");
const { publicRouter } = require("./routes/public");
const { whatsappRouter } = require("./routes/whatsapp");

async function initializeDatabase() {
  try {
    // Check DATABASE_URL first - if mock, skip all PostgreSQL attempts
    const dbUrl = process.env.DATABASE_URL;
    console.log(
      `[AFRIPULSE] Database URL type: ${dbUrl === "mock" ? "mock" : "postgresql"}`,
    );

    if (dbUrl === "mock") {
      console.log("[AFRIPULSE] Using mock database - no initialization needed");
      return;
    }

    const { getPool } = require("./db/client");
    const pool = getPool();

    // Check if we're using PostgreSQL and need to run migrations
    if (pool.constructor.name !== "MockPool") {
      console.log("[AFRIPULSE] Initializing PostgreSQL database...");

      // Run migrations
      const { spawn } = require("child_process");
      await new Promise((resolve, reject) => {
        const migrate = spawn("node", ["src/db/migrate.js"], {
          cwd: process.cwd(),
          stdio: "inherit",
        });
        migrate.on("close", (code) => {
          if (code === 0) resolve();
          else reject(new Error(`Migration failed with code ${code}`));
        });
      });

      // Run seed data
      await new Promise((resolve, reject) => {
        const seed = spawn("node", ["src/db/seed.js"], {
          cwd: process.cwd(),
          stdio: "inherit",
        });
        seed.on("close", (code) => {
          if (code === 0) resolve();
          else reject(new Error(`Seed failed with code ${code}`));
        });
      });
    }

    console.log("[AFRIPULSE] Database initialization completed");
  } catch (error) {
    console.error("[AFRIPULSE] Database initialization failed:", error.message);
    console.log("[AFRIPULSE] Falling back to mock database...");
    // Switch to mock database
    process.env.DATABASE_URL = "mock";
    console.log("[AFRIPULSE] Mock database initialized");
  }
}

const app = express();

// Configure CORS for Coolify deployment
const corsOptions = {
  origin: function (origin, callback) {
    // Allow all origins in development/production
    callback(null, true);
  },
  credentials: true,
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With"],
};

app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'", "'unsafe-inline'"],
        imgSrc: ["'self'", "data:", "https:"],
        connectSrc: ["'self'"],
      },
    },
  }),
);
app.use(cors(corsOptions));
app.use(express.json({ limit: "2mb" }));
app.use(morgan("combined"));

// Add request logging for debugging
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

app.use("/health", healthRouter);
app.use("/public", publicRouter);
app.use("/whatsapp", whatsappRouter);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error("[AFRIPULSE] Error:", err.stack);
  res.status(500).json({
    error: "Internal Server Error",
    message:
      process.env.NODE_ENV === "development"
        ? err.message
        : "Something went wrong",
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: "Not Found", path: req.url });
});

async function startServer() {
  try {
    // Log startup info
    console.log(`[AFRIPULSE] Starting server...`);
    console.log(
      `[AFRIPULSE] NODE_ENV: ${process.env.NODE_ENV || "development"}`,
    );
    console.log(`[AFRIPULSE] PORT: ${process.env.PORT || 8080}`);
    console.log(
      `[AFRIPULSE] DATABASE_URL: ${process.env.DATABASE_URL || "not set"}`,
    );

    await initializeDatabase();

    const port = Number(process.env.PORT || 8080);
    app.listen(port, "0.0.0.0", () => {
      console.log(`[AFRIPULSE] server listening on :${port}`);
      console.log(
        `[AFRIPULSE] Environment: ${process.env.NODE_ENV || "development"}`,
      );
      console.log(
        `[AFRIPULSE] Database URL: ${process.env.DATABASE_URL ? "configured" : "using mock"}`,
      );
      console.log(`[AFRIPULSE] Health check: http://localhost:${port}/health`);
    });
  } catch (error) {
    console.error("[AFRIPULSE] Failed to start server:", error);
    process.exit(1);
  }
}

startServer();
