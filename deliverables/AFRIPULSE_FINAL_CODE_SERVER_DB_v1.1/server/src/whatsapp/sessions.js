const { query } = require('../db/client');

async function getOpenSession(respondentId){
  const r = await query(
    `SELECT id, module_id FROM survey_sessions
     WHERE respondent_id=$1 AND status='OPEN'
     ORDER BY started_at DESC
     LIMIT 1`,
    [respondentId]
  );
  return r.rows[0] || null;
}

async function openSession(respondentId, moduleId){
  const r = await query(
    `INSERT INTO survey_sessions(respondent_id, module_id)
     VALUES ($1,$2)
     RETURNING id, module_id`,
    [respondentId, moduleId]
  );
  return r.rows[0];
}

async function recordAnswer(sessionId, questionId, answer){
  await query(
    `INSERT INTO survey_answers(session_id, question_id, answer)
     VALUES ($1,$2,$3::jsonb)`,
    [sessionId, questionId, JSON.stringify(answer)]
  );
}

async function startOrContinueSession({ respondentId, text }){
  let sess = await getOpenSession(respondentId);
  if (!sess) sess = await openSession(respondentId, 'MEDIA_DAILY');

  const a = await query(`SELECT question_id FROM survey_answers WHERE session_id=$1 ORDER BY created_at ASC`, [sess.id]);
  const answered = a.rows.map(x => x.question_id);

  if (!answered.includes('Q_MEDIA_CAT')) {
    await recordAnswer(sess.id, 'Q_MEDIA_CAT', { value: text.toUpperCase() });
    return;
  }

  if (!answered.includes('Q_MEDIA_OUTLET')) {
    await recordAnswer(sess.id, 'Q_MEDIA_OUTLET', { value: text });
    const catRow = await query(`SELECT answer->>'value' AS cat FROM survey_answers WHERE session_id=$1 AND question_id='Q_MEDIA_CAT' LIMIT 1`, [sess.id]);
    const cat = (catRow.rows[0]?.cat || 'ONLINE').toUpperCase();
    await query(`INSERT INTO media_daily_events(respondent_id,country_iso2,category,outlet_name) VALUES ($1,'NG',$2,$3)`, [respondentId, cat, text]);
    await query(`UPDATE survey_sessions SET status='CLOSED', closed_at=now() WHERE id=$1`, [sess.id]);
    return;
  }
}

module.exports = { startOrContinueSession };
