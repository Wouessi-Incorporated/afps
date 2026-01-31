# AFRIPULSE Website v1 (static)

## Run locally
Open `index.html` in a browser.

## Connect to your API
The demo dashboard calls the backend endpoint:
- GET /public/media-shares?country=NG&category=TV|RADIO|ONLINE|SOCIAL|ALL

Set the API base URL by opening the console and running:
```js
window.AFRIPULSE_API = "https://your-api-domain.com"
```
Then refresh `dashboard.html`.

## Deploy
- Netlify / Vercel / Cloudflare Pages: upload this folder as static site.
- Or serve via Nginx as `/var/www/afripulse`.
