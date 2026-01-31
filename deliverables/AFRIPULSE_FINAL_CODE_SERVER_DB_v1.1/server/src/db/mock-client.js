// Mock database client for local development without PostgreSQL
class MockPool {
  constructor() {
    this.data = {
      countries: [
        { iso2: "NG", name: "Nigeria", default_language: "en" },
        { iso2: "ZA", name: "South Africa", default_language: "en" },
        { iso2: "KE", name: "Kenya", default_language: "en" },
        { iso2: "EG", name: "Egypt", default_language: "en" },
        { iso2: "MA", name: "Morocco", default_language: "fr" },
        { iso2: "CM", name: "Cameroon", default_language: "fr" },
        { iso2: "SN", name: "Senegal", default_language: "fr" },
        { iso2: "CI", name: "Côte d'Ivoire", default_language: "fr" },
      ],
      survey_modules: [
        {
          id: "MEDIA_DAILY",
          name: "Media daily audience",
          cadence: "daily",
          is_active: true,
        },
        {
          id: "CORP_WEEKLY",
          name: "Corporate Heartbeat weekly",
          cadence: "weekly",
          is_active: true,
        },
      ],
      survey_questions: [
        {
          id: "Q_MEDIA_CAT",
          module_id: "MEDIA_DAILY",
          question_type: "single",
          prompt: "Which media category did you use MOST today?",
          choices: ["TV", "RADIO", "ONLINE", "SOCIAL"],
          meta: {},
          is_active: true,
        },
        {
          id: "Q_MEDIA_OUTLET",
          module_id: "MEDIA_DAILY",
          question_type: "text",
          prompt:
            "Name the outlet/channel/site/app you used most in that category",
          choices: null,
          meta: {},
          is_active: true,
        },
        {
          id: "Q_CORP_OPT",
          module_id: "CORP_WEEKLY",
          question_type: "scale",
          prompt: "How optimistic are you for the next 3 months? (1-5)",
          choices: null,
          meta: { min: 1, max: 5 },
          is_active: true,
        },
        {
          id: "Q_CORP_HIRE",
          module_id: "CORP_WEEKLY",
          question_type: "single",
          prompt: "In the next 3 months, will your company change headcount?",
          choices: ["INCREASE", "STABLE", "DECREASE", "UNCERTAIN"],
          meta: {},
          is_active: true,
        },
      ],
      media_daily_events: [
        {
          id: "1",
          respondent_id: "mock-1",
          country_iso2: "NG",
          category: "TV",
          outlet_name: "Channels TV",
          created_at: new Date(),
        },
        {
          id: "2",
          respondent_id: "mock-2",
          country_iso2: "NG",
          category: "TV",
          outlet_name: "NTA",
          created_at: new Date(),
        },
        {
          id: "3",
          respondent_id: "mock-3",
          country_iso2: "NG",
          category: "TV",
          outlet_name: "Channels TV",
          created_at: new Date(),
        },
        {
          id: "4",
          respondent_id: "mock-4",
          country_iso2: "NG",
          category: "RADIO",
          outlet_name: "Cool FM",
          created_at: new Date(),
        },
        {
          id: "5",
          respondent_id: "mock-5",
          country_iso2: "NG",
          category: "RADIO",
          outlet_name: "Wazobia FM",
          created_at: new Date(),
        },
        {
          id: "6",
          respondent_id: "mock-6",
          country_iso2: "NG",
          category: "ONLINE",
          outlet_name: "Punch",
          created_at: new Date(),
        },
        {
          id: "7",
          respondent_id: "mock-7",
          country_iso2: "NG",
          category: "ONLINE",
          outlet_name: "Vanguard",
          created_at: new Date(),
        },
        {
          id: "8",
          respondent_id: "mock-8",
          country_iso2: "NG",
          category: "SOCIAL",
          outlet_name: "Facebook",
          created_at: new Date(),
        },
        {
          id: "9",
          respondent_id: "mock-9",
          country_iso2: "NG",
          category: "SOCIAL",
          outlet_name: "Twitter",
          created_at: new Date(),
        },
        {
          id: "10",
          respondent_id: "mock-10",
          country_iso2: "NG",
          category: "SOCIAL",
          outlet_name: "Instagram",
          created_at: new Date(),
        },
        {
          id: "11",
          respondent_id: "mock-11",
          country_iso2: "ZA",
          category: "TV",
          outlet_name: "SABC",
          created_at: new Date(),
        },
        {
          id: "12",
          respondent_id: "mock-12",
          country_iso2: "ZA",
          category: "RADIO",
          outlet_name: "5FM",
          created_at: new Date(),
        },
      ],
      respondents: [],
      survey_sessions: [],
      survey_answers: [],
      media_outlets: [],
      corp_daily_signals: [],
      opt_outs: [],
    };
  }

  async query(text, params = []) {
    console.log("[MockDB] Query:", text, "Params:", params);

    // Handle COUNT queries for media shares
    if (
      text.includes("COUNT(*)::int AS total") &&
      text.includes("media_daily_events")
    ) {
      const country = params[0];
      const category = params[1];

      let filtered = this.data.media_daily_events.filter(
        (event) => event.country_iso2 === country,
      );

      if (category && category !== "ALL") {
        filtered = filtered.filter((event) => event.category === category);
      }

      return {
        rows: [{ total: filtered.length }],
      };
    }

    // Handle GROUP BY queries for media shares
    if (
      text.includes("GROUP BY outlet_name") &&
      text.includes("media_daily_events")
    ) {
      const country = params[0];
      const category = params[1];

      let filtered = this.data.media_daily_events.filter(
        (event) => event.country_iso2 === country,
      );

      if (category && category !== "ALL") {
        filtered = filtered.filter((event) => event.category === category);
      }

      // Group by outlet_name
      const grouped = {};
      filtered.forEach((event) => {
        if (!grouped[event.outlet_name]) {
          grouped[event.outlet_name] = 0;
        }
        grouped[event.outlet_name]++;
      });

      const rows = Object.entries(grouped)
        .map(([item, responses]) => ({ item, responses }))
        .sort((a, b) => b.responses - a.responses)
        .slice(0, 200);

      return { rows };
    }

    // Handle health check query
    if (text.includes("SELECT 1")) {
      return { rows: [{ "?column?": 1 }] };
    }

    // Handle INSERT queries
    if (text.includes("INSERT INTO countries")) {
      return { rows: [] };
    }

    if (text.includes("INSERT INTO survey_modules")) {
      return { rows: [] };
    }

    if (text.includes("INSERT INTO survey_questions")) {
      return { rows: [] };
    }

    // Default response
    return { rows: [] };
  }

  async end() {
    console.log("[MockDB] Connection ended");
  }
}

let pool;
function getPool() {
  if (!pool) {
    pool = new MockPool();
    console.log("[MockDB] Created mock database pool");
  }
  return pool;
}

async function query(text, params) {
  const p = getPool();
  return await p.query(text, params);
}

module.exports = { getPool, query };
