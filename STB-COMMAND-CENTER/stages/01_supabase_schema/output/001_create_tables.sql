-- ═════════════════════════════════════════════════════════════════
-- STB Command Center — 001_create_tables.sql
-- Stage 01 · Supabase Schema + Auth
--
-- Creates all 6 tables and enables Row Level Security on every one.
-- RLS is enabled HERE, before any policy exists (002), so there is no
-- window in which a table is readable without a policy governing it.
--
-- Run order: 001 → 002 → 003 → 004 → seed
-- Source of truth: _config/supabase/schema.sql
-- ═════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─────────────────────────────────────────────────────────────────
-- TABLE: practitioners
-- One row per human. id is the Supabase auth user id — the practitioner
-- record cannot exist without an auth user, and dies with it.
-- ─────────────────────────────────────────────────────────────────
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

-- ─────────────────────────────────────────────────────────────────
-- TABLE: daily_entries
-- The Today screen. One Focus, One Action, One Step — one row per day.
-- ─────────────────────────────────────────────────────────────────
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
  UNIQUE (practitioner_id, date)       -- One-Room Rule: one day, one room
);

-- ─────────────────────────────────────────────────────────────────
-- TABLE: evidence_logs
-- Evidence Over Vibes. did_it is boolean NOT NULL — true or false.
-- Not a 1-5 scale. Not "how well". Not nullable. Both values are
-- valid data; the absence of a row is the only "no answer".
-- ─────────────────────────────────────────────────────────────────
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

-- ─────────────────────────────────────────────────────────────────
-- TABLE: sprint_tasks
-- The Sprint Board. Operator creates the tasks; the practitioner
-- checks them off and can raise a trip wire on any one of them.
-- ─────────────────────────────────────────────────────────────────
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
  updated_at           timestamptz NOT NULL DEFAULT now(),
  CHECK (sprint_day <= sprint_total)
);

-- ─────────────────────────────────────────────────────────────────
-- TABLE: offers
-- The Offer Clarity screen. leak_zones is constrained to the same six
-- zones as sprint_tasks.leak_zone so the two screens cannot drift.
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE offers (
  id                   uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  practitioner_id      uuid NOT NULL REFERENCES practitioners(id) ON DELETE CASCADE,
  name                 text NOT NULL,
  one_sentence         text,
  price                numeric(10, 2) CHECK (price IS NULL OR price >= 0),
  status               text NOT NULL DEFAULT 'draft'
                         CHECK (status IN ('draft', 'live', 'paused')),
  is_first_doorway     boolean NOT NULL DEFAULT false,
  leak_zones           text[] NOT NULL DEFAULT '{}',
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT offers_leak_zones_valid CHECK (
    leak_zones <@ ARRAY[
      'offer_clarity', 'operations', 'visibility',
      'pricing', 'delivery', 'mindset'
    ]::text[]
  )
);

-- ─────────────────────────────────────────────────────────────────
-- TABLE: ai_suggestions
-- Consent Before Extraction. Claude never acts. Claude suggests.
-- confirmed defaults false and is only ever set true by a human
-- pressing Confirm. Nothing in this schema sets it to true.
-- ─────────────────────────────────────────────────────────────────
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
  created_at           timestamptz NOT NULL DEFAULT now(),
  CHECK (NOT (confirmed AND dismissed))   -- a suggestion is one or the other
);

-- ═════════════════════════════════════════════════════════════════
-- ENABLE ROW LEVEL SECURITY — all 6 tables, before any policy exists.
-- With RLS on and no policy, the default is deny-all. 002 opens
-- exactly the doors that should be open.
-- ═════════════════════════════════════════════════════════════════
ALTER TABLE practitioners   ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_entries   ENABLE ROW LEVEL SECURITY;
ALTER TABLE evidence_logs   ENABLE ROW LEVEL SECURITY;
ALTER TABLE sprint_tasks    ENABLE ROW LEVEL SECURITY;
ALTER TABLE offers          ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_suggestions  ENABLE ROW LEVEL SECURITY;
