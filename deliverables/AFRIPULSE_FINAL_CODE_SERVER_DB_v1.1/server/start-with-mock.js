// AFRIPULSE Server Startup Script with Forced Mock Database
// This script ensures the server always uses mock database, bypassing PostgreSQL entirely

console.log('[AFRIPULSE] Starting with forced mock database...');

// Force environment variables for mock database
process.env.DATABASE_URL = 'mock';
process.env.NODE_ENV = process.env.NODE_ENV || 'production';

console.log('[AFRIPULSE] Environment forced to:');
console.log(`[AFRIPULSE] NODE_ENV: ${process.env.NODE_ENV}`);
console.log(`[AFRIPULSE] PORT: ${process.env.PORT || 8080}`);
console.log(`[AFRIPULSE] DATABASE_URL: ${process.env.DATABASE_URL}`);

// Import required modules
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");

const { healthRouter } = require("./src/routes/health");
const { publicRouter } = require("./src/routes/public");
const { whatsappRouter } = require("./src/routes/whatsapp");

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
    message: process.env.NODE_ENV === "development" ? err.message : "Something went wrong",
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: "Not Found", path: req.url });
});

// Start server function
async function startServer() {
  try {
    const port = Number(process.env.PORT || 8080);

    console.log('[AFRIPULSE] Mock database is ready - no initialization needed');

    app.listen(port, "0.0.0.0", () => {
      console.log(`[AFRIPULSE] server listening on :${port}`);
      console.log(`[AFRIPULSE] Environment: ${process.env.NODE_ENV}`);
      console.log(`[AFRIPULSE] Database: mock (ready with sample data)`);
      console.log(`[AFRIPULSE] Health check: http://localhost:${port}/health`);
      console.log(`[AFRIPULSE] API ready: http://localhost:${port}/public/media-shares?country=NG&category=ALL`);
      console.log('[AFRIPULSE] ✅ Server started successfully with mock database!');
    });
  } catch (error) {
    console.error("[AFRIPULSE] Failed to start server:", error);
    process.exit(1);
  }
}

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('[AFRIPULSE] Received SIGTERM, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('[AFRIPULSE] Received SIGINT, shutting down gracefully...');
  process.exit(0);
});

// Start the server
startServer();
