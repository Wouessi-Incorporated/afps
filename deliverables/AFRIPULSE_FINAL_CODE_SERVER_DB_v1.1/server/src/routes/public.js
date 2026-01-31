const express = require('express');
const { getMediaShares } = require('../services/media');
const publicRouter = express.Router();

publicRouter.get('/media-shares', async (req,res) => {
  const country = (req.query.country || 'NG').toUpperCase();
  const category = (req.query.category || 'ALL').toUpperCase();
  const data = await getMediaShares({ country, category });
  res.json(data);
});

module.exports = { publicRouter };
