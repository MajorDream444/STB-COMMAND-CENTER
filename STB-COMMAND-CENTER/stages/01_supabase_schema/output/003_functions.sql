-- ═════════════════════════════════════════════════════════════════
-- STB Command Center — 003_functions.sql
-- Stage 01 · Supabase Schema + Auth
--
-- calculate_momentum_score() + the triggers that keep the schema
-- honest. Requires: 001_create_tables.sql
--
-- (is_operator() lives in 002 because the policies in that file
-- depend on it and each file must run standalone in order.)
-- ═════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────
-- FUNCTION: calculate_momentum_score(practitioner_id)
--
-- Returns an integer 0–100. Computed, never felt, never set by hand.
--
--   last 7 days   (today back through today-6)   = 70 points max
--   previous 7    (today-7 back through today-13)= 30 points max
--   streak bonus  +2 per consecutive day, capped +20
--   total capped at 100, floored at 0
--
-- A practitioner who logged did_it on all 14 days scores 100 on the
-- weighted portion alone; the streak bonus is what the cap absorbs.
-- Zero evidence logs returns 0.
--
-- THE PENDING-ROW ARGUMENTS
-- The trigger below fires BEFORE INSERT, so the row being written is
-- not yet visible to a query against evidence_logs. Calling the
-- one-argument form from that trigger would store a score computed
-- from every log EXCEPT the one being logged — a practitioner would
-- log day one and see a momentum score of 0.
--
-- p_pending_date / p_pending_did_it let the trigger hand the in-flight
-- row to the calculation. The row replaces any stored row for the
-- same date (the UPDATE case), so re-logging a day corrects the score
-- rather than double-counting it. Both default NULL, so the plain
--   SELECT calculate_momentum_score('<uuid>');
-- still works for manual checks and for reading a practitioner's live
-- score between logs.
-- ─────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION calculate_momentum_score(
  p_id             uuid,
  p_pending_date   date    DEFAULT NULL,
  p_pending_did_it boolean DEFAULT NULL
)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
  WITH logs AS (
    -- stored rows, minus any row the pending row is about to replace
    SELECT e.date, e.did_it
      FROM evidence_logs e
     WHERE e.practitioner_id = p_id
       AND (p_pending_date IS NULL OR e.date <> p_pending_date)
    UNION ALL
    -- the row currently being inserted or updated, if any
    SELECT p_pending_date, p_pending_did_it
     WHERE p_pending_date IS NOT NULL
  ),
  hits AS (
    -- only completed reps count. did_it = false is real data, but it
    -- is not evidence of a rep, so it scores nothing and breaks a streak.
    SELECT date
      FROM logs
     WHERE did_it
       AND date <= CURRENT_DATE     -- ignore any future-dated row
  ),
  windows AS (
    SELECT
      count(*) FILTER (WHERE date >  CURRENT_DATE - 7)                          AS recent_hits,
      count(*) FILTER (WHERE date >  CURRENT_DATE - 14
                         AND date <= CURRENT_DATE - 7)                          AS older_hits
      FROM hits
  ),
  -- Gaps-and-islands: rank the hit days newest-first. Within one
  -- unbroken run of calendar days, (age - rank) is constant. The run
  -- containing the newest hit is the current streak.
  ranked AS (
    SELECT (CURRENT_DATE - date)::int                          AS age,
           (row_number() OVER (ORDER BY date DESC))::int - 1   AS rn
      FROM hits
  ),
  streak AS (
    SELECT CASE
             -- newest hit older than yesterday: the streak is over.
             -- Today unlogged does not break it; the practitioner
             -- still has today to log.
             WHEN (SELECT min(age) FROM ranked) > 1 THEN 0
             ELSE (SELECT count(*) FROM ranked
                    WHERE age - rn = (SELECT min(age) FROM ranked))
           END AS days
  )
  SELECT GREATEST(0, LEAST(100,
           round(  (LEAST(w.recent_hits, 7)::numeric / 7) * 70
                 + (LEAST(w.older_hits,  7)::numeric / 7) * 30 )::int
           + LEAST(s.days * 2, 20)
         ))
    FROM windows w, streak s;
$$;

COMMENT ON FUNCTION calculate_momentum_score(uuid, date, boolean) IS
  'Momentum 0-100. Last 7 days weighted 70, prior 7 weighted 30, +2 per '
  'consecutive day capped at +20. Pending args let the BEFORE trigger '
  'include the row being written. Zero logs returns 0.';

-- ─────────────────────────────────────────────────────────────────
-- TRIGGER: store the momentum score on every evidence log write
--
-- BEFORE INSERT OR UPDATE, so the score is written into the row
-- itself with no second statement and no recursion.
--
-- The stored momentum_score is a SNAPSHOT — what momentum was at the
-- moment that rep was logged. Older rows are intentionally not
-- rewritten when a new log lands; the history of the score is itself
-- evidence. For a practitioner's CURRENT score (e.g. the Today
-- screen, before they have logged today) call the function directly:
--   SELECT calculate_momentum_score(auth.uid());
-- ─────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_momentum_on_log()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.momentum_score := calculate_momentum_score(
    NEW.practitioner_id, NEW.date, NEW.did_it
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS evidence_log_momentum ON evidence_logs;
CREATE TRIGGER evidence_log_momentum
  BEFORE INSERT OR UPDATE ON evidence_logs
  FOR EACH ROW EXECUTE FUNCTION update_momentum_on_log();

-- ─────────────────────────────────────────────────────────────────
-- TRIGGER: updated_at maintenance
-- evidence_logs is absent on purpose — it has no updated_at column,
-- because an evidence log is a record of a moment, not a document.
-- ─────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS practitioners_updated_at ON practitioners;
CREATE TRIGGER practitioners_updated_at
  BEFORE UPDATE ON practitioners
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS daily_entries_updated_at ON daily_entries;
CREATE TRIGGER daily_entries_updated_at
  BEFORE UPDATE ON daily_entries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS sprint_tasks_updated_at ON sprint_tasks;
CREATE TRIGGER sprint_tasks_updated_at
  BEFORE UPDATE ON sprint_tasks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS offers_updated_at ON offers;
CREATE TRIGGER offers_updated_at
  BEFORE UPDATE ON offers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ─────────────────────────────────────────────────────────────────
-- TRIGGER: ai_suggestions may never be born confirmed
--
-- Consent Before Extraction, enforced in the database rather than
-- trusted to every future caller. A row arrives unconfirmed no
-- matter what the inserting code claims; only a subsequent UPDATE
-- — a human pressing Confirm — can set it true.
-- ─────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION enforce_unconfirmed_on_insert()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.confirmed := false;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS ai_suggestions_never_born_confirmed ON ai_suggestions;
CREATE TRIGGER ai_suggestions_never_born_confirmed
  BEFORE INSERT ON ai_suggestions
  FOR EACH ROW EXECUTE FUNCTION enforce_unconfirmed_on_insert();
