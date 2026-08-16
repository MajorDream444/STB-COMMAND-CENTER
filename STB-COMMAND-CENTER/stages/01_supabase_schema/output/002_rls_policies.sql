-- ═════════════════════════════════════════════════════════════════
-- STB Command Center — 002_rls_policies.sql
-- Stage 01 · Supabase Schema + Auth
--
-- Grants and Row Level Security policies for all 6 tables.
-- RLS was already enabled in 001, so until this file runs every
-- table is deny-all. Requires: 001_create_tables.sql
--
-- Three access shapes:
--   anon         → nothing. No anonymous reads on any table.
--   authenticated→ own rows only (auth.uid() = practitioner_id)
--   operator     → read all rows; write only where the operator is
--                  the one who authors the content (sprint tasks,
--                  check-in drafts)
--   service_role → bypasses RLS entirely (Postgres superuser role).
--                  Used by the Vercel serverless function in Stage 05.
--                  It needs NO policy — see the note at the bottom.
-- ═════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────
-- OPERATOR HELPER
--
-- Why this exists: the obvious operator check is an inline
--   EXISTS (SELECT 1 FROM practitioners WHERE id = auth.uid()
--           AND tier = 'operator')
-- but placing that inside a POLICY ON practitioners makes the
-- policy query the very table it guards. Postgres re-applies RLS to
-- that subquery and the evaluation recurses:
--   ERROR: infinite recursion detected in policy for relation "practitioners"
--
-- A SECURITY DEFINER function runs as its owner, and a table owner
-- bypasses RLS by default — so the lookup inside is_operator() is
-- not re-filtered and the recursion never starts. It is also
-- evaluated once per statement instead of once per row.
--
-- search_path is pinned so the function cannot be hijacked by a
-- caller-controlled schema.
-- ─────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION is_operator()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1 FROM practitioners
     WHERE id = auth.uid()
       AND tier = 'operator'
  );
$$;

REVOKE ALL     ON FUNCTION is_operator() FROM PUBLIC, anon;
GRANT  EXECUTE ON FUNCTION is_operator() TO authenticated;

-- ─────────────────────────────────────────────────────────────────
-- GRANTS
-- RLS filters WHICH ROWS. Grants decide WHICH VERBS are even
-- possible. Both have to agree before a query succeeds.
--
-- anon gets nothing: an unauthenticated visitor has no reason to
-- touch any of these tables. The only anonymous surface in this app
-- is the magic-link sign-in, which Supabase handles in auth schema.
-- ─────────────────────────────────────────────────────────────────
REVOKE ALL ON practitioners, daily_entries, evidence_logs,
              sprint_tasks, offers, ai_suggestions
  FROM anon;

GRANT SELECT, INSERT, UPDATE ON practitioners   TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON daily_entries  TO authenticated;
GRANT SELECT, INSERT, UPDATE ON evidence_logs   TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON sprint_tasks   TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON offers         TO authenticated;
GRANT SELECT, UPDATE         ON ai_suggestions  TO authenticated;

-- evidence_logs has no DELETE grant on purpose. Evidence Over Vibes:
-- a logged rep is a fact. A practitioner can correct today's entry
-- (UPDATE, guarded by UNIQUE(practitioner_id, date)) but cannot
-- erase history to make a streak look better than it was.

-- ─────────────────────────────────────────────────────────────────
-- practitioners
-- ─────────────────────────────────────────────────────────────────
CREATE POLICY "practitioners_self_read"
  ON practitioners FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "practitioners_self_insert"
  ON practitioners FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- WITH CHECK repeats the USING clause so a practitioner cannot
-- rewrite practitioner_id and hand their row to someone else.
CREATE POLICY "practitioners_self_update"
  ON practitioners FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "practitioners_operator_read"
  ON practitioners FOR SELECT
  TO authenticated
  USING (is_operator());

-- ─────────────────────────────────────────────────────────────────
-- daily_entries
-- ─────────────────────────────────────────────────────────────────
CREATE POLICY "daily_entries_self"
  ON daily_entries FOR ALL
  TO authenticated
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "daily_entries_operator_read"
  ON daily_entries FOR SELECT
  TO authenticated
  USING (is_operator());

-- ─────────────────────────────────────────────────────────────────
-- evidence_logs
-- ─────────────────────────────────────────────────────────────────
CREATE POLICY "evidence_logs_self"
  ON evidence_logs FOR ALL
  TO authenticated
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "evidence_logs_operator_read"
  ON evidence_logs FOR SELECT
  TO authenticated
  USING (is_operator());

-- ─────────────────────────────────────────────────────────────────
-- sprint_tasks
-- Practitioner reads and updates (check off, raise a trip wire).
-- Practitioner cannot INSERT or DELETE — the sprint is authored by
-- the operator. A practitioner who can add their own tasks can
-- quietly rewrite the sprint, which defeats the point of the sprint.
-- ─────────────────────────────────────────────────────────────────
CREATE POLICY "sprint_tasks_self_read"
  ON sprint_tasks FOR SELECT
  TO authenticated
  USING (auth.uid() = practitioner_id);

CREATE POLICY "sprint_tasks_self_update"
  ON sprint_tasks FOR UPDATE
  TO authenticated
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "sprint_tasks_operator_all"
  ON sprint_tasks FOR ALL
  TO authenticated
  USING (is_operator())
  WITH CHECK (is_operator());

-- ─────────────────────────────────────────────────────────────────
-- offers
-- ─────────────────────────────────────────────────────────────────
CREATE POLICY "offers_self"
  ON offers FOR ALL
  TO authenticated
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "offers_operator_read"
  ON offers FOR SELECT
  TO authenticated
  USING (is_operator());

-- ─────────────────────────────────────────────────────────────────
-- ai_suggestions
-- The practitioner reads their suggestions and confirms or dismisses
-- them. They cannot INSERT — suggestions originate from the Stage 05
-- serverless function (service_role) or from an operator. That is
-- what makes "Claude suggested this" a claim the row can support.
-- ─────────────────────────────────────────────────────────────────
CREATE POLICY "ai_suggestions_self_read"
  ON ai_suggestions FOR SELECT
  TO authenticated
  USING (auth.uid() = practitioner_id);

CREATE POLICY "ai_suggestions_self_update"
  ON ai_suggestions FOR UPDATE
  TO authenticated
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "ai_suggestions_operator_all"
  ON ai_suggestions FOR ALL
  TO authenticated
  USING (is_operator())
  WITH CHECK (is_operator());

-- ─────────────────────────────────────────────────────────────────
-- NOTE ON THE SERVICE ROLE — deliberately no policy.
--
-- The reference file _config/supabase/rls_policies.sql carried a
-- policy "ai_suggestions_service_insert" with WITH CHECK (true),
-- commented "restricted at application layer via service role key".
-- It is dropped here for two reasons:
--
--   1. It does not do what the comment says. An unqualified policy
--      applies to every role that can INSERT, so any signed-in
--      practitioner could have written an ai_suggestions row for
--      ANY practitioner_id — including a fake "Claude said so"
--      suggestion in another practitioner's feed.
--   2. service_role does not need it. It is a Postgres role with
--      BYPASSRLS; policies are never consulted for it at all.
--
-- The Stage 05 serverless function authenticates with
-- SUPABASE_SERVICE_ROLE_KEY and writes suggestions without any
-- policy grant. That key must stay server-side, never in a VITE_ var.
-- ─────────────────────────────────────────────────────────────────
