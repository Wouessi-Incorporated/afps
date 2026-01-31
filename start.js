#!/usr/bin/env node

const { spawn } = require('child_process');
const path = require('path');

console.log('🚀 Starting AFRIPULSE System...\n');

const ROOT_DIR = __dirname;
const SERVER_DIR = path.join(ROOT_DIR, 'deliverables', 'AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1', 'server');
const WEBSITE_DIR = path.join(ROOT_DIR, 'deliverables', 'AFRIPULSE_FINAL_WEBSITE_v1');

// Color codes for console output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

function log(color, prefix, message) {
  console.log(`${colors[color]}[${prefix}]${colors.reset} ${message}`);
}

// Track running processes
const processes = [];

// Cleanup function
function cleanup() {
  log('yellow', 'CLEANUP', 'Shutting down all processes...');
  processes.forEach(proc => {
    if (proc && !proc.killed) {
      proc.kill('SIGTERM');
    }
  });
  process.exit(0);
}

// Handle cleanup on exit
process.on('SIGINT', cleanup);
process.on('SIGTERM', cleanup);
process.on('exit', cleanup);

async function startServer() {
  return new Promise((resolve, reject) => {
    log('blue', 'SERVER', 'Starting backend API server...');

    const serverProcess = spawn('node', ['src/index.js'], {
      cwd: SERVER_DIR,
      env: {
        ...process.env,
        DATABASE_URL: 'mock',
        PORT: '8080'
      },
      stdio: 'pipe'
    });

    processes.push(serverProcess);

    serverProcess.stdout.on('data', (data) => {
      const output = data.toString().trim();
      if (output) {
        log('blue', 'SERVER', output);
        if (output.includes('server listening on :8080')) {
          resolve(serverProcess);
        }
      }
    });

    serverProcess.stderr.on('data', (data) => {
      const output = data.toString().trim();
      if (output) {
        log('red', 'SERVER-ERR', output);
      }
    });

    serverProcess.on('error', (error) => {
      log('red', 'SERVER-ERR', `Failed to start: ${error.message}`);
      reject(error);
    });

    serverProcess.on('exit', (code) => {
      if (code !== 0) {
        log('red', 'SERVER', `Process exited with code ${code}`);
      }
    });

    // Timeout if server doesn't start within 10 seconds
    setTimeout(() => {
      if (serverProcess.exitCode === null) {
        log('yellow', 'SERVER', 'Server started (assuming success after timeout)');
        resolve(serverProcess);
      }
    }, 10000);
  });
}

async function startWebsite() {
  return new Promise((resolve, reject) => {
    log('green', 'WEBSITE', 'Starting frontend website server...');

    const websiteProcess = spawn('node', ['server.js'], {
      cwd: WEBSITE_DIR,
      env: {
        ...process.env,
        PORT: '3000'
      },
      stdio: 'pipe'
    });

    processes.push(websiteProcess);

    websiteProcess.stdout.on('data', (data) => {
      const output = data.toString().trim();
      if (output) {
        log('green', 'WEBSITE', output);
        if (output.includes('Server running on http://localhost:3000')) {
          resolve(websiteProcess);
        }
      }
    });

    websiteProcess.stderr.on('data', (data) => {
      const output = data.toString().trim();
      if (output) {
        log('red', 'WEBSITE-ERR', output);
      }
    });

    websiteProcess.on('error', (error) => {
      log('red', 'WEBSITE-ERR', `Failed to start: ${error.message}`);
      reject(error);
    });

    websiteProcess.on('exit', (code) => {
      if (code !== 0) {
        log('red', 'WEBSITE', `Process exited with code ${code}`);
      }
    });

    // Timeout if website doesn't start within 5 seconds
    setTimeout(() => {
      if (websiteProcess.exitCode === null) {
        log('yellow', 'WEBSITE', 'Website started (assuming success after timeout)');
        resolve(websiteProcess);
      }
    }, 5000);
  });
}

async function testEndpoints() {
  const http = require('http');

  log('cyan', 'TEST', 'Testing API endpoints...');

  return new Promise((resolve) => {
    // Test health endpoint
    const healthReq = http.get('http://localhost:8080/health', (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          if (result.ok) {
            log('cyan', 'TEST', '✅ Health endpoint working');
          } else {
            log('red', 'TEST', '❌ Health endpoint returned error');
          }
        } catch (e) {
          log('red', 'TEST', '❌ Health endpoint returned invalid JSON');
        }

        // Test media shares endpoint
        const mediaReq = http.get('http://localhost:8080/public/media-shares?country=NG&category=ALL', (res2) => {
          let data2 = '';
          res2.on('data', (chunk) => data2 += chunk);
          res2.on('end', () => {
            try {
              const result2 = JSON.parse(data2);
              if (result2.country && result2.total !== undefined) {
                log('cyan', 'TEST', '✅ Media shares endpoint working');
                log('cyan', 'TEST', `Found ${result2.total} responses for ${result2.country}`);
              } else {
                log('red', 'TEST', '❌ Media shares endpoint returned unexpected data');
              }
            } catch (e) {
              log('red', 'TEST', '❌ Media shares endpoint returned invalid JSON');
            }
            resolve();
          });
        }).on('error', (e) => {
          log('red', 'TEST', `❌ Media shares endpoint error: ${e.message}`);
          resolve();
        });
      });
    }).on('error', (e) => {
      log('red', 'TEST', `❌ Health endpoint error: ${e.message}`);
      resolve();
    });
  });
}

async function main() {
  try {
    // Start backend server
    await startServer();

    // Wait a moment for server to fully initialize
    await new Promise(resolve => setTimeout(resolve, 2000));

    // Start frontend website
    await startWebsite();

    // Wait a moment for website to fully initialize
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Test endpoints
    await testEndpoints();

    console.log('\n' + '='.repeat(60));
    log('green', 'SUCCESS', '🎉 AFRIPULSE System is now running!');
    console.log('');
    log('blue', 'API', '📡 Backend API: http://localhost:8080');
    log('blue', 'API', '   - Health: http://localhost:8080/health');
    log('blue', 'API', '   - Media: http://localhost:8080/public/media-shares?country=NG&category=ALL');
    console.log('');
    log('green', 'WEB', '🌐 Frontend Website: http://localhost:3000');
    log('green', 'WEB', '   - Homepage: http://localhost:3000/');
    log('green', 'WEB', '   - Dashboard: http://localhost:3000/dashboard.html');
    console.log('');
    log('yellow', 'INFO', '💡 The dashboard connects to the API automatically');
    log('yellow', 'INFO', '💾 Using in-memory mock database (no PostgreSQL required)');
    log('yellow', 'INFO', '📊 Sample data is pre-loaded for Nigeria, South Africa, etc.');
    console.log('');
    log('magenta', 'CTRL+C', '🛑 Press Ctrl+C to stop all servers');
    console.log('='.repeat(60) + '\n');

    // Keep the process alive
    process.stdin.resume();

  } catch (error) {
    log('red', 'ERROR', `Failed to start system: ${error.message}`);
    cleanup();
    process.exit(1);
  }
}

// Run the main function
main();
