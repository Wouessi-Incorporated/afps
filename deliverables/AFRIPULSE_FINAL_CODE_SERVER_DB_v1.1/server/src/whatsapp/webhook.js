const crypto = require('crypto');
const { upsertRespondent, logOptOut } = require('./respondents');
const { startOrContinueSession } = require('./sessions');

function hashPhone(phone){
  return crypto.createHash('sha256').update(phone).digest('hex');
}

function parseProviderPayload(req){
  if (req.body && req.body.From && req.body.Body) {
    return { from: req.body.From, text: String(req.body.Body).trim() };
  }
  return { from: req.body?.from || '', text: String(req.body?.text || '').trim() };
}

async function verifyWebhook(req,res){
  const mode = req.query['hub.mode'];
  const token = req.query['hub.verify_token'];
  const challenge = req.query['hub.challenge'];
  if (mode === 'subscribe' && token && token === process.env.WHATSAPP_WEBHOOK_VERIFY_TOKEN) {
    return res.status(200).send(challenge);
  }
  return res.status(403).send('Forbidden');
}

async function handleIncomingMessage(req,res){
  try{
    const { from, text } = parseProviderPayload(req);
    if (!from) return res.status(200).send('OK');

    const phoneHash = hashPhone(from);

    if (/^(stop|unsubscribe|optout)$/i.test(text)) {
      await logOptOut(phoneHash);
      return res.status(200).send('OK');
    }

    const respondent = await upsertRespondent({ phoneHash });
    await startOrContinueSession({ respondentId: respondent.id, text });

    return res.status(200).send('OK');
  }catch(e){
    console.error(e);
    return res.status(200).send('OK');
  }
}

module.exports = { handleIncomingMessage, verifyWebhook };
