-- STB Command Center — Row Level Security Policies
-- Apply after schema.sql

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
-- Own row only (free + paid)
CREATE POLICY "practitioners_self_read"
  ON practitioners FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "practitioners_self_update"
  ON practitioners FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "practitioners_self_insert"
  ON practitioners FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Operators can read all practitioners
CREATE POLICY "practitioners_operator_read"
  ON practitioners FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM practitioners p
      WHERE p.id = auth.uid() AND p.tier = 'operator'
    )
  );

-- ─────────────────────────────────────────
-- daily_entries
-- ─────────────────────────────────────────
CREATE POLICY "daily_entries_self"
  ON daily_entries FOR ALL
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "daily_entries_operator_read"
  ON daily_entries FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM practitioners p
      WHERE p.id = auth.uid() AND p.tier = 'operator'
    )
  );

-- ─────────────────────────────────────────
-- evidence_logs
-- ─────────────────────────────────────────
CREATE POLICY "evidence_logs_self"
  ON evidence_logs FOR ALL
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "evidence_logs_operator_read"
  ON evidence_logs FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM practitioners p
      WHERE p.id = auth.uid() AND p.tier = 'operator'
    )
  );

-- ─────────────────────────────────────────
-- sprint_tasks
-- ─────────────────────────────────────────
-- Practitioners can read + update their own tasks (mark done, flag trip wire)
-- Operators can create, read, update all tasks
CREATE POLICY "sprint_tasks_self_read_update"
  ON sprint_tasks FOR SELECT
  USING (auth.uid() = practitioner_id);

CREATE POLICY "sprint_tasks_self_update"
  ON sprint_tasks FOR UPDATE
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "sprint_tasks_operator_all"
  ON sprint_tasks FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM practitioners p
      WHERE p.id = auth.uid() AND p.tier = 'operator'
    )
  );

-- ─────────────────────────────────────────
-- offers
-- ─────────────────────────────────────────
CREATE POLICY "offers_self"
  ON offers FOR ALL
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "offers_operator_read"
  ON offers FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM practitioners p
      WHERE p.id = auth.uid() AND p.tier = 'operator'
    )
  );

-- ─────────────────────────────────────────
-- ai_suggestions
-- ─────────────────────────────────────────
-- Practitioners can read their own suggestions and confirm/dismiss them
-- Operators can create suggestions (check-in drafts) for any practitioner
CREATE POLICY "ai_suggestions_self_read"
  ON ai_suggestions FOR SELECT
  USING (auth.uid() = practitioner_id);

CREATE POLICY "ai_suggestions_self_update"
  ON ai_suggestions FOR UPDATE
  USING (auth.uid() = practitioner_id)
  WITH CHECK (auth.uid() = practitioner_id);

CREATE POLICY "ai_suggestions_operator_all"
  ON ai_suggestions FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM practitioners p
      WHERE p.id = auth.uid() AND p.tier = 'operator'
    )
  );

-- Service role can insert suggestions (from Vercel serverless function)
CREATE POLICY "ai_suggestions_service_insert"
  ON ai_suggestions FOR INSERT
  WITH CHECK (true);  -- Restricted at application layer via service role key
