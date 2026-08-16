-- STB Command Center — Canonical Supabase Schema
-- Layer 3 reference · Source of truth for all stages
-- Last updated: 2026-08-16

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─────────────────────────────────────────
-- TABLE: practitioners
-- ─────────────────────────────────────────
CREATE TABLE practitioners (
  id                   uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name                 text,
  email                text UNIQUE NOT NULL,
  tier                 text NOT NULL DEFAULT 'free'
                         CHECK (tier IN ('free', 'paid', 'operator')),
  onboarding_complete  boolean NOT NULL DEFAULT false,
  one_sentence         text,           -- "I help [person] do [thing] so they can [result]"
  bleed_zone           text,           -- the one thing costing them clients right now
  stability_goal       text,           -- what "stable" looks like for them
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);

-- ─────────────────────────────────────────
-- TABLE: daily_entries
-- ─────────────────────────────────────────
CREATE TABLE daily_entries (
  id                   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  practitioner_id      uuid NOT NULL REFERENCES practitioners(id) ON DELETE CASCADE,
  date                 date NOT NULL,
  one_focus            text,
  one_action           text,
  one_step             text,           -- optional micro-task beneath the action
  action_done          boolean NOT NULL DEFAULT false,
  note                 text,           -- optional short reflection
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),
  UNIQUE (practitioner_id, date)
);

-- ─────────────────────────────────────────
-- TABLE: evidence_logs
-- ─────────────────────────────────────────
-- Binary only. No scale. No partial credit. Did it or didn't.
CREATE TABLE evidence_logs (
  id                   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  practitioner_id      uuid NOT NULL REFERENCES practitioners(id) ON DELETE CASCADE,
  date                 date NOT NULL,
  did_it               boolean NOT NULL,   -- true = did it, false = didn't. NO NULL.
  note                 text CHECK (length(note) <= 140),
  momentum_score       integer CHECK (momentum_score BETWEEN 0 AND 100),
  created_at           timestamptz NOT NULL DEFAULT now(),
  UNIQUE (practitioner_id, date)           -- one log per day
);

-- ─────────────────────────────────────────
-- TABLE: sprint_tasks
-- ─────────────────────────────────────────
CREATE TABLE sprint_tasks (
  id                   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  practitioner_id      uuid NOT NULL REFERENCES practitioners(id) ON DELETE CASCADE,
  sprint_day           integer NOT NULL CHECK (sprint_day BETWEEN 1 AND 14),
  sprint_total         integer NOT NULL DEFAULT 7 CHECK (sprint_total IN (7, 14)),
  name                 text NOT NULL,
  leak_zone            text NOT NULL
                         CHECK (leak_zone IN (
                           'offer_clarity', 'operations', 'visibility',
                           'pricing', 'delivery', 'mindset'
                         )),
  done                 boolean NOT NULL DEFAULT false,
  order_index          integer NOT NULL DEFAULT 0,
  trip_wire_flagged    boolean NOT NULL DEFAULT false,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);

-- ─────────────────────────────────────────
-- TABLE: offers
-- ─────────────────────────────────────────
CREATE TABLE offers (
  id                   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  practitioner_id      uuid NOT NULL REFERENCES practitioners(id) ON DELETE CASCADE,
  name                 text NOT NULL,
  one_sentence         text,
  price                numeric(10, 2),
  status               text NOT NULL DEFAULT 'draft'
                         CHECK (status IN ('draft', 'live', 'paused')),
  is_first_doorway     boolean NOT NULL DEFAULT false,
  leak_zones           text[] NOT NULL DEFAULT '{}',
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);

-- Only one first doorway per practitioner
CREATE UNIQUE INDEX offers_one_first_doorway
  ON offers (practitioner_id)
  WHERE is_first_doorway = true;

-- ─────────────────────────────────────────
-- TABLE: ai_suggestions
-- ─────────────────────────────────────────
-- Claude never acts. Claude suggests. Humans confirm.
CREATE TABLE ai_suggestions (
  id                   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  practitioner_id      uuid NOT NULL REFERENCES practitioners(id) ON DELETE CASCADE,
  type                 text NOT NULL
                         CHECK (type IN (
                           'next_action', 'pattern_insight',
                           'trip_wire', 'check_in_draft'
                         )),
  content              text NOT NULL,
  confirmed            boolean NOT NULL DEFAULT false,  -- NEVER auto-set to true
  dismissed            boolean NOT NULL DEFAULT false,
  created_at           timestamptz NOT NULL DEFAULT now()
);

-- ─────────────────────────────────────────
-- INDEXES
-- ─────────────────────────────────────────
CREATE INDEX evidence_logs_practitioner_date ON evidence_logs (practitioner_id, date DESC);
CREATE INDEX daily_entries_practitioner_date ON daily_entries (practitioner_id, date DESC);
CREATE INDEX sprint_tasks_practitioner_done  ON sprint_tasks (practitioner_id, done);
CREATE INDEX ai_suggestions_practitioner     ON ai_suggestions (practitioner_id, confirmed, dismissed);

-- ─────────────────────────────────────────
-- FUNCTION: calculate_momentum_score
-- ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION calculate_momentum_score(p_id uuid)
RETURNS integer AS $$
DECLARE
  recent_score    numeric := 0;
  older_score     numeric := 0;
  streak_bonus    integer := 0;
  streak_count    integer := 0;
  consecutive     boolean := true;
  log_row         RECORD;
  final_score     integer;
BEGIN
  -- Edge case: no logs → return 0
  IF NOT EXISTS (SELECT 1 FROM evidence_logs WHERE practitioner_id = p_id) THEN
    RETURN 0;
  END IF;

  -- Last 7 days = 70% weight
  SELECT COUNT(*) * 10 INTO recent_score
  FROM evidence_logs
  WHERE practitioner_id = p_id
    AND date >= CURRENT_DATE - INTERVAL '7 days'
    AND did_it = true;
  recent_score := recent_score * 0.7;

  -- Previous 7 days (8–14 days ago) = 30% weight
  SELECT COUNT(*) * 10 INTO older_score
  FROM evidence_logs
  WHERE practitioner_id = p_id
    AND date BETWEEN CURRENT_DATE - INTERVAL '14 days' AND CURRENT_DATE - INTERVAL '8 days'
    AND did_it = true;
  older_score := older_score * 0.3;

  -- Streak bonus: consecutive days from today, +2 per day, max +20
  FOR log_row IN
    SELECT date, did_it
    FROM evidence_logs
    WHERE practitioner_id = p_id
    ORDER BY date DESC
    LIMIT 14
  LOOP
    IF consecutive AND log_row.did_it THEN
      streak_count := streak_count + 1;
      streak_bonus := LEAST(streak_count * 2, 20);
    ELSE
      consecutive := false;
    END IF;
  END LOOP;

  final_score := LEAST(ROUND(recent_score + older_score)::integer + streak_bonus, 100);
  RETURN GREATEST(final_score, 0);
END;
$$ LANGUAGE plpgsql;

-- ─────────────────────────────────────────
-- TRIGGER: auto-calculate momentum on evidence log insert
-- ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_momentum_on_log()
RETURNS TRIGGER AS $$
BEGIN
  NEW.momentum_score := calculate_momentum_score(NEW.practitioner_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER evidence_log_momentum
  BEFORE INSERT OR UPDATE ON evidence_logs
  FOR EACH ROW EXECUTE FUNCTION update_momentum_on_log();

-- ─────────────────────────────────────────
-- TRIGGER: updated_at timestamps
-- ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER practitioners_updated_at
  BEFORE UPDATE ON practitioners
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER daily_entries_updated_at
  BEFORE UPDATE ON daily_entries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER sprint_tasks_updated_at
  BEFORE UPDATE ON sprint_tasks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER offers_updated_at
  BEFORE UPDATE ON offers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
