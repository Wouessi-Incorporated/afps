# AFRIPULSE System - Quick Start Guide

🚀 **Get the complete AFRIPULSE system running in under 2 minutes!**

## Prerequisites

- **Node.js** (v16 or higher) - [Download here](https://nodejs.org/)
- No database setup required! Uses in-memory mock data.

## One-Command Setup

```bash
node start.js
```

That's it! The system will automatically:
1. Install dependencies for the backend server
2. Start the API server on port 8080
3. Start the website on port 3000
4. Test all endpoints
5. Display access URLs

## What You Get

### 🌐 Frontend Website (Port 3000)
- **Homepage**: http://localhost:3000/
- **Interactive Dashboard**: http://localhost:3000/dashboard.html
- **Product Pages**: All pages are fully functional
- **Multi-language**: English/French support
- **Mobile Responsive**: Works on all devices

### 📡 Backend API (Port 8080)
- **Health Check**: http://localhost:8080/health
- **Media Data**: http://localhost:8080/public/media-shares?country=NG&category=ALL
- **WhatsApp Webhook**: Ready for integration
- **Mock Database**: Pre-loaded with sample data

## Sample Data Included

The system comes with realistic sample data for:
- 🇳🇬 Nigeria - TV (Channels TV, NTA), Radio (Cool FM, Wazobia FM)
- 🇿🇦 South Africa - TV (SABC), Radio (5FM)
- 🇰🇪 Kenya, 🇪🇬 Egypt, 🇲🇦 Morocco, 🇨🇲 Cameroon, 🇸🇳 Senegal, 🇨🇮 Côte d'Ivoire

## Key Features Demonstrated

### Dashboard
- Real-time media consumption analytics
- Country/category filtering
- Response statistics and market shares
- Interactive charts and KPIs

### API Endpoints
- Media shares aggregation
- Multi-country support
- Category filtering (TV, Radio, Online, Social)
- JSON responses with percentage calculations

### WhatsApp Integration
- Webhook endpoint ready
- Survey flow implementation
- Opt-out handling
- Multi-language support

## Architecture

```
┌─────────────────┐    HTTP API    ┌─────────────────┐
│   Frontend      │◄──────────────►│   Backend       │
│   (Port 3000)   │                │   (Port 8080)   │
│                 │                │                 │
│ • Dashboard     │                │ • Express.js    │
│ • Multi-pages   │                │ • Mock Database │
│ • Multi-lang    │                │ • WhatsApp API  │
└─────────────────┘                └─────────────────┘
```

## File Structure

```
AFRIPULSE_FINAL_ALL_IN_ONE_v1.2/
├── start.js                 # 🚀 Main startup script
├── QUICKSTART.md           # 📖 This file
└── deliverables/
    ├── AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/
    │   └── server/
    │       ├── src/
    │       │   ├── index.js           # Main server
    │       │   ├── db/mock-client.js  # Mock database
    │       │   ├── routes/            # API endpoints
    │       │   └── services/          # Business logic
    │       └── package.json
    └── AFRIPULSE_FINAL_WEBSITE_v1/
        ├── server.js           # Static file server
        ├── index.html         # Homepage
        ├── dashboard.html     # Main dashboard
        ├── app.js            # Frontend logic
        ├── styles.css        # Styling
        └── i18n/             # Translations
```

## Next Steps for Production

### Database Setup
Replace the mock database with PostgreSQL:
1. Install PostgreSQL
2. Update `DATABASE_URL` in environment
3. Run `npm run migrate && npm run seed`

### WhatsApp Integration
1. Get Twilio credentials
2. Update environment variables
3. Configure webhook URL

### Deployment
- **Backend**: Deploy to Heroku/AWS/DigitalOcean
- **Frontend**: Deploy to Netlify/Vercel/Cloudflare Pages

## Troubleshooting

### Port Already in Use
```bash
# Kill processes on ports 3000 and 8080
npx kill-port 3000 8080
node start.js
```

### Dependencies Issues
```bash
cd deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server
npm install
cd ../../../
node start.js
```

## Development Mode

For development with auto-reload:
```bash
# Terminal 1 - Backend
cd deliverables/AFRIPULSE_FINAL_CODE_SERVER_DB_v1.1/server
DATABASE_URL=mock npm run dev

# Terminal 2 - Frontend
cd deliverables/AFRIPULSE_FINAL_WEBSITE_v1
node server.js
```

## API Examples

### Get Media Shares for Nigeria
```bash
curl "http://localhost:8080/public/media-shares?country=NG&category=ALL"
```

### Filter by TV Category
```bash
curl "http://localhost:8080/public/media-shares?country=NG&category=TV"
```

### Health Check
```bash
curl "http://localhost:8080/health"
```

## Support

For questions or issues:
1. Check the console output for error messages
2. Ensure Node.js is properly installed
3. Verify ports 3000 and 8080 are available
4. All sample data is in `server/src/db/mock-client.js`

---

🎉 **Enjoy exploring AFRIPULSE!** 

The system is ready for demonstration, testing, and further development.