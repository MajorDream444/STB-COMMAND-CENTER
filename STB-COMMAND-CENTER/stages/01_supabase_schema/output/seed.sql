-- ═════════════════════════════════════════════════════════════════
-- STB Command Center — seed.sql
-- Stage 01 · Supabase Schema + Auth
--
-- Sample data for ONE practitioner (Major) so every screen in
-- Stages 02–05 has something real to render against.
--
-- Requires: 001 → 002 → 003 → 004 already applied.
--
-- ─────────────────────────────────────────────────────────────────
-- BEFORE YOU RUN THIS
--
-- practitioners.id is a foreign key to auth.users(id), so the auth
-- user has to exist first. Sign in once with the magic link at the
-- email below, then run this file. It looks the user up by email and
-- fails with a readable message if the sign-in has not happened yet.
--
-- Change the email on the next line if you seed a different account.
-- ─────────────────────────────────────────────────────────────────
--
-- Idempotent: re-running replaces this practitioner's seed rows
-- rather than duplicating them. Safe to run as many times as you like.
-- Run it in the Supabase SQL editor (service role — bypasses RLS).
-- ═════════════════════════════════════════════════════════════════

DO $$
DECLARE
  v_seed_email  text := 'major@hanzo.ai';
  v_id          uuid;
  v_offer_id    uuid;
  r             record;
BEGIN
  -- ── Resolve the auth user ───────────────────────────────────────
  SELECT id INTO v_id FROM auth.users WHERE email = v_seed_email;

  IF v_id IS NULL THEN
    RAISE EXCEPTION
      'No auth user found for %. Sign in once with the magic link at that address, then re-run seed.sql.',
      v_seed_email;
  END IF;

  -- ── Clear any previous seed for this practitioner ───────────────
  -- Child rows first; the FKs are ON DELETE CASCADE, but being
  -- explicit keeps the intent readable.
  DELETE FROM ai_suggestions WHERE practitioner_id = v_id;
  DELETE FROM evidence_logs  WHERE practitioner_id = v_id;
  DELETE FROM daily_entries  WHERE practitioner_id = v_id;
  DELETE FROM sprint_tasks   WHERE practitioner_id = v_id;
  DELETE FROM offers         WHERE practitioner_id = v_id;

  -- ── practitioners (1 row) ───────────────────────────────────────
  INSERT INTO practitioners (
    id, name, email, tier, onboarding_complete,
    one_sentence, bleed_zone, stability_goal
  ) VALUES (
    v_id,
    'Major Dream Williams',
    v_seed_email,
    'operator',
    true,
    'I help overwhelmed gifted practitioners build one clear offer and one repeatable system so they stop bleeding clients.',
    'Too many half-built offers, no single first doorway.',
    'Three predictable client conversations a week without a launch.'
  )
  ON CONFLICT (id) DO UPDATE SET
    name                = EXCLUDED.name,
    tier                = EXCLUDED.tier,
    onboarding_complete = EXCLUDED.onboarding_complete,
    one_sentence        = EXCLUDED.one_sentence,
    bleed_zone          = EXCLUDED.bleed_zone,
    stability_goal      = EXCLUDED.stability_goal;

  -- ── evidence_logs (14 rows, oldest first) ───────────────────────
  -- Inserted oldest-first so each row's stored momentum_score is a
  -- true snapshot of momentum at the moment that rep was logged.
  -- The pattern is deliberately imperfect: two missed days, one
  -- inside each weighting window, and a live 4-day streak.
  --
  -- Expected momentum on the newest row:
  --   recent window (days 0-6): 6 hits → 6/7 * 70 = 60.0
  --   prior window  (days 7-13): 6 hits → 6/7 * 30 = 25.7
  --   base = round(85.7) = 86
  --   streak = 4 consecutive days → +8
  --   total = 94
  FOR r IN
    SELECT * FROM (VALUES
      (13, true,  'Wrote the offer sentence. Ugly but written.'),
      (12, true,  'Sent it to two people. No replies yet.'),
      (11, false, 'Rewrote the website instead. Avoidance.'),
      (10, true,  'One outreach message. Felt like a lot.'),
      ( 9, true,  NULL),
      ( 8, true,  'Second reply came in.'),
      ( 7, true,  'Booked the first conversation.'),
      ( 6, true,  NULL),
      ( 5, true,  'Held the price. Did not discount.'),
      ( 4, false, 'Travel day. Chose rest.'),
      ( 3, true,  'Back to it. Sent two messages.'),
      ( 2, true,  NULL),
      ( 1, true,  'Third conversation booked.'),
      ( 0, true,  'Logged before coffee. That is the habit.')
    ) AS t(days_ago, did_it, note)
    ORDER BY days_ago DESC
  LOOP
    INSERT INTO evidence_logs (practitioner_id, date, did_it, note)
    VALUES (v_id, CURRENT_DATE - r.days_ago, r.did_it, r.note);
    -- momentum_score is set by the evidence_log_momentum trigger.
  END LOOP;

  -- ── daily_entries (3 rows) ──────────────────────────────────────
  INSERT INTO daily_entries (
    practitioner_id, date, one_focus, one_action, one_step, action_done, note
  ) VALUES
    (v_id, CURRENT_DATE - 2,
     'Get the first doorway live.',
     'Publish the Stop the Bleed Sprint page.',
     'Paste the one-sentence offer at the top.',
     true,  'Went live at 4pm.'),
    (v_id, CURRENT_DATE - 1,
     'Fill the sprint.',
     'Message three people who already asked about it.',
     NULL,
     true,  NULL),
    (v_id, CURRENT_DATE,
     'Hold the room.',
     'Run the 10am call without rebuilding the deck first.',
     'Open the existing deck. Do not open Figma.',
     false, NULL);

  -- ── sprint_tasks (7-day sprint, mixed leak zones) ───────────────
  INSERT INTO sprint_tasks (
    practitioner_id, sprint_day, sprint_total, name, leak_zone,
    done, order_index, trip_wire_flagged
  ) VALUES
    (v_id, 1, 7, 'Write the one-sentence offer',            'offer_clarity', true,  0, false),
    (v_id, 2, 7, 'Pick the single first doorway',           'offer_clarity', true,  1, false),
    (v_id, 3, 7, 'Set the price and stop moving it',        'pricing',       true,  2, false),
    (v_id, 4, 7, 'Write the intake questions',              'operations',    false, 3, false),
    (v_id, 5, 7, 'Send five direct messages',               'visibility',    false, 4, true),
    (v_id, 6, 7, 'Build the session-one outline',           'delivery',      false, 5, false),
    (v_id, 7, 7, 'Name the story you tell when it is quiet','mindset',       false, 6, false);

  -- ── offers (2 rows, exactly one first doorway) ──────────────────
  INSERT INTO offers (
    practitioner_id, name, one_sentence, price, status,
    is_first_doorway, leak_zones
  ) VALUES (
    v_id,
    'Stop the Bleed Sprint',
    'A seven-day sprint that finds the one leak costing you clients and closes it.',
    1200.00,
    'live',
    true,
    ARRAY['offer_clarity', 'pricing', 'visibility']
  )
  RETURNING id INTO v_offer_id;

  INSERT INTO offers (
    practitioner_id, name, one_sentence, price, status,
    is_first_doorway, leak_zones
  ) VALUES (
    v_id,
    'Build While You Heal',
    'The continuity layer after the bleed stops — build the business at the pace your body allows.',
    3600.00,
    'draft',
    false,
    ARRAY['operations', 'delivery', 'mindset']
  );

  -- ── ai_suggestions (2 rows, both unconfirmed) ───────────────────
  -- confirmed is forced false by the ai_suggestions_never_born_confirmed
  -- trigger regardless of what is written here. Consent before extraction.
  INSERT INTO ai_suggestions (practitioner_id, type, content) VALUES
    (v_id, 'next_action',
     'You have booked three conversations and written none of the intake questions. Draft the intake before the 10am call so the call has a shape.'),
    (v_id, 'pattern_insight',
     'Your two missed days both followed a day with an outreach task. Visibility work is the one that costs you the next morning — consider putting it after the delivery block, not before.');

  RAISE NOTICE 'Seed complete for % (%).', v_seed_email, v_id;
END $$;

-- ─────────────────────────────────────────────────────────────────
-- Expected row counts after this file runs
--   practitioners   1
--   daily_entries   3
--   evidence_logs  14
--   sprint_tasks    7
--   offers          2
--   ai_suggestions  2
--
-- Verify the momentum score landed:
--   SELECT date, did_it, momentum_score
--     FROM evidence_logs
--    WHERE practitioner_id = (SELECT id FROM practitioners WHERE email = 'major@hanzo.ai')
--    ORDER BY date DESC LIMIT 5;
--
-- The newest row should read 94, and
--   SELECT calculate_momentum_score(id) FROM practitioners WHERE email = 'major@hanzo.ai';
-- should agree.
-- ─────────────────────────────────────────────────────────────────
