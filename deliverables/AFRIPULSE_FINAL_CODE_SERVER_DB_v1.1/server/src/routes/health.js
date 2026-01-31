const express = require('express');
const { query } = require('../db/client');
const healthRouter = express.Router();

healthRouter.get('/', async (req,res) => {
  try{
    await query('SELECT 1');
    res.json({ ok:true, ts: new Date().toISOString() });
  }catch(e){
    res.status(500).json({ ok:false, error: e.message });
  }
});

module.exports = { healthRouter };
