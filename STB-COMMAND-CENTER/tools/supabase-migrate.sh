#!/bin/bash
# STB Command Center — Supabase Migration Runner
# Applies Stage 01 output to your Supabase project
#
# Usage: bash tools/supabase-migrate.sh
# Requires: Supabase CLI installed (https://supabase.com/docs/guides/cli)

set -e

STAGE_OUTPUT="stages/01_supabase_schema/output"
CONFIG_SQL="_config/supabase"

echo "STB Command Center — Supabase Migration"
echo "========================================"

# Check Supabase CLI
if ! command -v supabase &> /dev/null; then
    echo "Error: Supabase CLI not found."
    echo "Install: https://supabase.com/docs/guides/cli"
    exit 1
fi

# Check output exists
if [ ! -d "$STAGE_OUTPUT" ]; then
    echo "Error: Stage 01 output not found at $STAGE_OUTPUT"
    echo "Run Stage 01 in Claude Code first."
    exit 1
fi

echo ""
echo "Files to apply (in order):"
echo "  1. $STAGE_OUTPUT/001_create_tables.sql"
echo "  2. $STAGE_OUTPUT/002_rls_policies.sql"
echo "  3. $STAGE_OUTPUT/003_functions.sql"
echo "  4. $STAGE_OUTPUT/004_indexes.sql"
echo "  5. $STAGE_OUTPUT/seed.sql (development only)"
echo ""
read -p "Apply to Supabase? (y/N) " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Applying schema..."
supabase db push --file "$STAGE_OUTPUT/001_create_tables.sql"
supabase db push --file "$STAGE_OUTPUT/002_rls_policies.sql"
supabase db push --file "$STAGE_OUTPUT/003_functions.sql"
supabase db push --file "$STAGE_OUTPUT/004_indexes.sql"

echo ""
read -p "Apply seed data? (development only) (y/N) " seed_confirm
if [ "$seed_confirm" == "y" ] || [ "$seed_confirm" == "Y" ]; then
    supabase db push --file "$STAGE_OUTPUT/seed.sql"
    echo "Seed data applied."
fi

echo ""
echo "Migration complete."
echo "Verify in your Supabase dashboard: https://app.supabase.com"
