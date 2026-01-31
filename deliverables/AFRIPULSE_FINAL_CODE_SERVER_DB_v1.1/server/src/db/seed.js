const { query, getPool } = require("./client");

async function run() {
  const pool = getPool();

  // Check if we're using mock database
  if (pool.constructor.name === "MockPool") {
    console.log("[seed] Using mock database - seed data already loaded");
    await pool.end();
    console.log("[seed] done");
    return;
  }

  await query(`INSERT INTO countries(iso2,name,default_language) VALUES
    ('NG','Nigeria','en'),
    ('ZA','South Africa','en'),
    ('KE','Kenya','en'),
    ('EG','Egypt','en'),
    ('MA','Morocco','fr'),
    ('CM','Cameroon','fr'),
    ('SN','Senegal','fr'),
    ('CI','Côte d'Ivoire','fr')
  ON CONFLICT (iso2) DO NOTHING;`);

  await query(`INSERT INTO survey_modules(id,name,cadence) VALUES
    ('MEDIA_DAILY','Media daily audience', 'daily'),
    ('CORP_WEEKLY','Corporate Heartbeat weekly', 'weekly')
  ON CONFLICT (id) DO NOTHING;`);

  await query(`INSERT INTO survey_questions(id,module_id,question_type,prompt,choices,meta) VALUES
    ('Q_MEDIA_CAT','MEDIA_DAILY','single','Which media category did you use MOST today?', '["TV","RADIO","ONLINE","SOCIAL"]'::jsonb, '{}'::jsonb),
    ('Q_MEDIA_OUTLET','MEDIA_DAILY','text','Name the outlet/channel/site/app you used most in that category','null'::jsonb,'{}'::jsonb),
    ('Q_CORP_OPT','CORP_WEEKLY','scale','How optimistic are you for the next 3 months? (1-5)','null'::jsonb,'{"min":1,"max":5}'::jsonb),
    ('Q_CORP_HIRE','CORP_WEEKLY','single','In the next 3 months, will your company change headcount?','["INCREASE","STABLE","DECREASE","UNCERTAIN"]'::jsonb,'{}'::jsonb)
  ON CONFLICT (id) DO NOTHING;`);

  await getPool().end();
  console.log("[seed] done");
}
run().catch((e) => {
  console.error(e);
  process.exit(1);
});
