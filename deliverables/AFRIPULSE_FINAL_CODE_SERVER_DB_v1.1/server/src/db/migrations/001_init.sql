-- AFRIPULSE schema v1 (PostgreSQL)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS countries (
  iso2 TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  default_language TEXT NOT NULL CHECK (default_language IN ('en','fr'))
);

CREATE TABLE IF NOT EXISTS respondents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_hash TEXT NOT NULL UNIQUE,
  country_iso2 TEXT NOT NULL REFERENCES countries(iso2),
  lang TEXT NOT NULL CHECK (lang IN ('en','fr')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_active_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS survey_modules (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  cadence TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS survey_questions (
  id TEXT PRIMARY KEY,
  module_id TEXT NOT NULL REFERENCES survey_modules(id),
  question_type TEXT NOT NULL,
  prompt TEXT NOT NULL,
  choices JSONB,
  meta JSONB,
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS survey_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  respondent_id UUID NOT NULL REFERENCES respondents(id),
  module_id TEXT NOT NULL REFERENCES survey_modules(id),
  status TEXT NOT NULL DEFAULT 'OPEN',
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  closed_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS survey_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES survey_sessions(id),
  question_id TEXT NOT NULL REFERENCES survey_questions(id),
  answer JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS media_outlets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  country_iso2 TEXT NOT NULL REFERENCES countries(iso2),
  category TEXT NOT NULL CHECK (category IN ('TV','RADIO','ONLINE','SOCIAL')),
  outlet_name TEXT NOT NULL,
  outlet_type TEXT NOT NULL,
  UNIQUE(country_iso2, category, outlet_name)
);

CREATE TABLE IF NOT EXISTS media_daily_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  respondent_id UUID NOT NULL REFERENCES respondents(id),
  country_iso2 TEXT NOT NULL REFERENCES countries(iso2),
  category TEXT NOT NULL CHECK (category IN ('TV','RADIO','ONLINE','SOCIAL')),
  outlet_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS corp_daily_signals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  respondent_id UUID NOT NULL REFERENCES respondents(id),
  country_iso2 TEXT NOT NULL REFERENCES countries(iso2),
  signal JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS opt_outs (
  phone_hash TEXT PRIMARY KEY,
  country_iso2 TEXT,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
