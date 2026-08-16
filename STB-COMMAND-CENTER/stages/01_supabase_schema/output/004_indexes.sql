-- ═════════════════════════════════════════════════════════════════
-- STB Command Center — 004_indexes.sql
-- Stage 01 · Supabase Schema + Auth
--
-- Requires: 001_create_tables.sql
--
-- Every index here backs a query the app actually makes. Nothing is
-- indexed speculatively — an index the app never uses still costs a
-- write on every insert.
-- ═════════════════════════════════════════════════════════════════

-- Evidence screen: the 7-day dot strip and the 14-day momentum
-- window both scan one practitioner's logs newest-first. DESC on
-- date matches that ordering so the planner reads the index forward.
CREATE INDEX IF NOT EXISTS evidence_logs_practitioner_date
  ON evidence_logs (practitioner_id, date DESC);

-- Today screen: "give me this practitioner's entry for this date".
CREATE INDEX IF NOT EXISTS daily_entries_practitioner_date
  ON daily_entries (practitioner_id, date DESC);

-- Sprint board: open tasks vs. the collapsed Completed section.
CREATE INDEX IF NOT EXISTS sprint_tasks_practitioner_done
  ON sprint_tasks (practitioner_id, done);

-- AI suggestion pill: the one pending suggestion to show is the one
-- that is neither confirmed nor dismissed.
CREATE INDEX IF NOT EXISTS ai_suggestions_practitioner
  ON ai_suggestions (practitioner_id, confirmed, dismissed);

-- ─────────────────────────────────────────────────────────────────
-- CONSTRAINT INDEX: one First Doorway per practitioner
--
-- A partial unique index rather than a plain UNIQUE, because the
-- rule is "at most one TRUE", not "at most one of each value". A
-- practitioner may have many offers with is_first_doorway = false;
-- the WHERE clause excludes those rows from the uniqueness check.
--
-- Enforced in the database because "which door do they walk through
-- first" is the single decision the Offer Clarity screen exists to
-- make. Two first doorways is the ambiguity the screen removes.
-- ─────────────────────────────────────────────────────────────────
CREATE UNIQUE INDEX IF NOT EXISTS offers_one_first_doorway
  ON offers (practitioner_id)
  WHERE is_first_doorway = true;

-- Operator cohort view (Stage 06) sorts the roster by tier. Cheap
-- index on a small table; listed now so the operator view does not
-- need a migration of its own to read the roster.
CREATE INDEX IF NOT EXISTS practitioners_tier
  ON practitioners (tier);
