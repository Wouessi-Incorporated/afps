const { query } = require('../db/client');

async function upsertRespondent({ phoneHash }){
  const country = 'NG';
  const lang = 'en';

  const r = await query(
    `INSERT INTO respondents(phone_hash, country_iso2, lang, last_active_at)
     VALUES ($1,$2,$3, now())
     ON CONFLICT (phone_hash) DO UPDATE SET last_active_at=now()
     RETURNING id, phone_hash, country_iso2, lang`,
    [phoneHash, country, lang]
  );
  return r.rows[0];
}

async function logOptOut(phoneHash){
  await query(
    `INSERT INTO opt_outs(phone_hash, reason)
     VALUES ($1,'user_request')
     ON CONFLICT (phone_hash) DO NOTHING`,
    [phoneHash]
  );
}

module.exports = { upsertRespondent, logOptOut };
