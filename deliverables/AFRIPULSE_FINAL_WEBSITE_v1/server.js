const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

// MIME types for different file extensions
const mimeTypes = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.eot': 'application/vnd.ms-fontobject'
};

function getMimeType(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  return mimeTypes[ext] || 'application/octet-stream';
}

function serveFile(res, filePath) {
  fs.readFile(filePath, (err, data) => {
    if (err) {
      if (err.code === 'ENOENT') {
        res.writeHead(404, { 'Content-Type': 'text/html' });
        res.end('<h1>404 Not Found</h1>');
      } else {
        res.writeHead(500, { 'Content-Type': 'text/html' });
        res.end('<h1>500 Internal Server Error</h1>');
      }
    } else {
      const mimeType = getMimeType(filePath);
      res.writeHead(200, { 'Content-Type': mimeType });
      res.end(data);
    }
  });
}

const server = http.createServer((req, res) => {
  // Enable CORS for API calls
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  const parsedUrl = url.parse(req.url);
  let pathname = parsedUrl.pathname;

  // Default to index.html if root path
  if (pathname === '/') {
    pathname = '/index.html';
  }

  // Construct file path
  const filePath = path.join(__dirname, pathname);

  // Security check - prevent directory traversal
  const resolvedPath = path.resolve(filePath);
  const rootPath = path.resolve(__dirname);

  if (!resolvedPath.startsWith(rootPath)) {
    res.writeHead(403, { 'Content-Type': 'text/html' });
    res.end('<h1>403 Forbidden</h1>');
    return;
  }

  // Check if file exists
  fs.stat(resolvedPath, (err, stats) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/html' });
      res.end('<h1>404 Not Found</h1>');
    } else if (stats.isFile()) {
      serveFile(res, resolvedPath);
    } else {
      res.writeHead(404, { 'Content-Type': 'text/html' });
      res.end('<h1>404 Not Found</h1>');
    }
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`[AFRIPULSE Website] Server running on http://localhost:${PORT}`);
  console.log('Available pages:');
  console.log('  - http://localhost:' + PORT + '/index.html (Homepage)');
  console.log('  - http://localhost:' + PORT + '/dashboard.html (Dashboard)');
  console.log('  - http://localhost:' + PORT + '/products.html (Products)');
  console.log('  - http://localhost:' + PORT + '/methodology.html (Methodology)');
  console.log('  - http://localhost:' + PORT + '/pricing.html (Pricing)');
  console.log('  - http://localhost:' + PORT + '/research.html (Research)');
  console.log('  - http://localhost:' + PORT + '/media.html (Media)');
  console.log('  - http://localhost:' + PORT + '/corporate.html (Corporate)');
});
