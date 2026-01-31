const express = require('express');
const { handleIncomingMessage, verifyWebhook } = require('../whatsapp/webhook');
const whatsappRouter = express.Router();

whatsappRouter.get('/webhook', verifyWebhook);
whatsappRouter.post('/webhook', handleIncomingMessage);

module.exports = { whatsappRouter };
