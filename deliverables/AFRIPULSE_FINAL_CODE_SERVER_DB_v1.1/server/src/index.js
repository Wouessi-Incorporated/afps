require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const { healthRouter } = require('./routes/health');
const { publicRouter } = require('./routes/public');
const { whatsappRouter } = require('./routes/whatsapp');

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '2mb' }));
app.use(morgan('combined'));

app.use('/health', healthRouter);
app.use('/public', publicRouter);
app.use('/whatsapp', whatsappRouter);

const port = Number(process.env.PORT || 8080);
app.listen(port, () => {
  console.log(`[AFRIPULSE] server listening on :${port}`);
});
