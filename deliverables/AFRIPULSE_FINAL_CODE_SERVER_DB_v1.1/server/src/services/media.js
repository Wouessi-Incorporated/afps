const { query } = require('../db/client');

async function getMediaShares({ country, category }){
  const params = [country];
  let catFilter = '';
  if (category && category !== 'ALL') {
    params.push(category);
    catFilter = 'AND category = $2';
  }
  const totalRes = await query(
    `SELECT COUNT(*)::int AS total
     FROM media_daily_events
     WHERE country_iso2=$1 ${catFilter}
       AND created_at >= now() - interval '7 days'`,
    params
  );
  const total = totalRes.rows[0]?.total || 0;

  const rowsRes = await query(
    `SELECT outlet_name AS item, COUNT(*)::int AS responses
     FROM media_daily_events
     WHERE country_iso2=$1 ${catFilter}
       AND created_at >= now() - interval '7 days'
     GROUP BY outlet_name
     ORDER BY responses DESC
     LIMIT 200`,
    params
  );

  const rows = rowsRes.rows.map(r => ({
    item: r.item,
    responses: r.responses,
    share: total ? (r.responses / total) : 0
  }));
  return { country, category, total, rows };
}

module.exports = { getMediaShares };
