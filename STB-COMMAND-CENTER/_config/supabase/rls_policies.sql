-- STB Command Center — Corrected RLS Policies
-- Fixes infinite recursion defect in operator policies
-- Replaces: _config/supabase/rls_policies.sql
--
-- ROOT CAUSE: The original operator policies used a subquery that
-- re-entered the practitioners table while RLS was active on it,
-- causing infinite recursion:
--   EXISTS (SELECT 1 FROM practitioners p WHERE p.id = auth.uid()
--           AND p.tier = 'operator')
-- This fires practitioners' own SELECT policy → which runs the same
-- EXISTS check → infinite loop.
--
-- FIX: Use a SECURITY DEFINER function that bypasses RLS to check
-- tier. The function runs as its owner (postgres), not the calling
-- user, so it reads the practitioners table without triggering RLS.

BEGIN;

-- ─────────────────────────────────────────
-- SECURITY DEFINER helper — bypasses RLS to check tier
-- ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION is_operator()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
-- search_path is pinned: a SECURITY DEFINER function runs as its
-- owner, so an unpinned search_path lets a caller shadow
-- `practitioners` with their own table and be handed owner rights.
SET search_path = public, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM practitioners
    WHERE id = auth.uid()
      AND tier = 'operator'
  );
$$;

-- Revoke public execute, grant only to authenticated users
REVOKE ALL ON FUNCTION is_operator() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION is_operator() TO authenticated;

-- ─────────────────────────────────────────
-- Idempotent re-apply: drop prior versions first
--
-- CREATE POLICY has no OR REPLACE, so re-running this file against a
-- database that already has these policies fails on the first one.
-- These drops make the file safe to apply repeatedly — including over
-- the original recursive policies, which share these exact names.
--
-- Dropping a policy while RLS stays enabled is safe: the table falls
-- back to deny-all for the moment between drop and create, rather than
-- opening up. Run the whole file in one transaction.
-- ─────────────────────────────────────────
DROP POLICY IF EXISTS "practitioners_self_read"     ON practitioners;
DROP POLICY IF EXISTS "practitioners_self_update"   ON practitioners;
DROP POLICY IF EXISTS "practitioners_self_insert"   ON practitioners;
DROP POLICY IF EXISTS "practitioners_operator_read" ON practitioners;
DROP POLICY IF EXISTS "daily_entries_self"          ON daily_entries;
DROP POLICY IF EXISTS "daily_entries_operator_read" ON daily_entries;
DROP POLICY IF EXISTS "evidence_logs_self"          ON evidence_logs;
DROP POLICY IF EXISTS "evidence_logs_operator_read" ON evidence_logs;
DROP POLICY IF EXISTS "sprint_tasks_self_read"      ON sprint_tasks;
DROP POLICY IF EXISTS "sprint_tasks_self_update"    ON sprint_tasks;
DROP POLICY IF EXISTS "sprint_tasks_operator_all"   ON sprint_tasks;
DROP POLICY IF EXISTS "offers_self"                 ON offers;
DROP POLICY IF EXISTS "offers_operator_read"        ON offers;
DROP POLICY IF EXISTS "ai_suggestions_self_read"    ON ai_suggestions;
DROP POLICY IF EXISTS "ai_suggestions_self_update"  ON ai_suggestions;
DROP POLICY IF EXISTS "ai_suggestions_operator_all" ON ai_suggestions;

-- ─────────────────────────────────────────
-- Enable RLS on all tables
-- ─────────────────────────────────────────
ALTER TABLE practitioners   ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_entries   ENABLE ROW LEVEL SECURITY;
ALTER TABLE evidence_logs   ENABLE ROW LEVEL SECURITY;
ALTER TABLE sprint_tasks    ENABLE ROW LEVEL SECURITY;
ALTER TABLE offers          ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_suggestions  ENABLE ROW LEVEL SECURITY;

-- ─────────────────────────────────────────
-- practitioners
-- ─────────────────────────────────────────
CREATE POLICY "practitioners_self_read"
  ON practitioners FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "practitioners_self_update"
  ON practitioners FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "practitioners_self_insert"
  ON practitioners FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Operator reads all — uses SECURITY DEFINER function, no recursion
CREATE POLICY "practitioners_operator_read"
  ON practitioners FOR SELECT
  USING (is_operator());

-- ─────────────────────────────────────────
-- daily_entries
-- ─────────────────────────────────────────
CREATE POLICY "daily_entries_self"
  ON daily_entries FOR ALL
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "daily_entries_operator_read"
  ON daily_entries FOR SELECT
  USING (is_operator());

-- ─────────────────────────────────────────
-- evidence_logs
-- ─────────────────────────────────────────
CREATE POLICY "evidence_logs_self"
  ON evidence_logs FOR ALL
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "evidence_logs_operator_read"
  ON evidence_logs FOR SELECT
  USING (is_operator());

-- ─────────────────────────────────────────
-- sprint_tasks
-- ─────────────────────────────────────────
-- Practitioners: read their own + update done/trip_wire_flagged
CREATE POLICY "sprint_tasks_self_read"
  ON sprint_tasks FOR SELECT
  USING (auth.uid() = practitioner_id);

CREATE POLICY "sprint_tasks_self_update"
  ON sprint_tasks FOR UPDATE
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

-- Operators: full access (create tasks, read all, update all)
CREATE POLICY "sprint_tasks_operator_all"
  ON sprint_tasks FOR ALL
  USING (is_operator())
  WITH CHECK (is_operator());

-- ─────────────────────────────────────────
-- offers
-- ─────────────────────────────────────────
CREATE POLICY "offers_self"
  ON offers FOR ALL
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "offers_operator_read"
  ON offers FOR SELECT
  USING (is_operator());

-- ─────────────────────────────────────────
-- ai_suggestions
-- ─────────────────────────────────────────
-- Practitioners: read + confirm/dismiss their own
CREATE POLICY "ai_suggestions_self_read"
  ON ai_suggestions FOR SELECT
  USING (auth.uid() = practitioner_id);

CREATE POLICY "ai_suggestions_self_update"
  ON ai_suggestions FOR UPDATE
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

-- Operators: full access (create check-in drafts, read all)
CREATE POLICY "ai_suggestions_operator_all"
  ON ai_suggestions FOR ALL
  USING (is_operator())
  WITH CHECK (is_operator());

-- NO service-role INSERT policy. Deliberate.
--
-- A previous revision carried:
--   CREATE POLICY "ai_suggestions_service_insert"
--     ON ai_suggestions FOR INSERT WITH CHECK (true);
-- described as "belt-and-suspenders for the anon key context only".
-- It was neither belt nor suspenders. A policy with no TO clause
-- applies to PUBLIC, so WITH CHECK (true) let ANY caller insert a
-- row for ANY practitioner_id. Verified against PostgreSQL 16 with
-- Supabase's stock grants: a free-tier practitioner AND a logged-out
-- anon both successfully wrote a fabricated "Claude said this"
-- suggestion into another practitioner's feed.
--
-- service_role does not need the policy. It holds BYPASSRLS, so
-- policies are never consulted for it. The Stage 05 serverless
-- function writes suggestions with SUPABASE_SERVICE_ROLE_KEY and is
-- unaffected by this removal.
--
-- Practitioners get SELECT + UPDATE only (read, confirm, dismiss).
-- That restriction is what lets the UI honestly say "Claude
-- suggested this" — the row could not have come from the client.

-- ─────────────────────────────────────────
-- VERIFICATION QUERIES
-- Run these after applying to confirm no recursion
-- ─────────────────────────────────────────
-- SELECT is_operator();  -- should return false for anon/non-operator
-- SELECT * FROM practitioners LIMIT 1;  -- should not hang
-- SELECT policyname, cmd FROM pg_policies
--   WHERE schemaname = 'public'
--   ORDER BY tablename, policyname;

COMMIT;
