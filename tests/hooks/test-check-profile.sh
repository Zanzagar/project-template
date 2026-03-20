#!/usr/bin/env bash
# Tests for the hook profile system (adapted from ECC architecture)
# Tests: check-hook-enabled.js CLI bridge + run-with-flags-shell.sh dispatcher
# Run: bash tests/hooks/test-check-profile.sh

set +e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CHECK_ENABLED="$PROJECT_ROOT/.claude/hooks/lib/check-hook-enabled.js"
RUN_WITH_FLAGS="$PROJECT_ROOT/.claude/hooks/lib/run-with-flags-shell.sh"

PASS=0
FAIL=0

assert_eq() {
  local test_name="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    PASS=$((PASS + 1))
    printf "  ok - %s\n" "$test_name"
  else
    FAIL=$((FAIL + 1))
    printf "  FAIL - %s (expected '%s', got '%s')\n" "$test_name" "$expected" "$actual"
  fi
}

echo "# Hook profile system tests (ECC-adapted architecture)"
echo ""

# ─── check-hook-enabled.js tests ───────────────────────────────
echo "## check-hook-enabled.js CLI bridge"

# Default profile (standard), hook declares standard,strict → yes
unset TEMPLATE_HOOK_PROFILE
unset TEMPLATE_DISABLED_HOOKS
RESULT=$(node "$CHECK_ENABLED" "my-hook" "standard,strict" 2>/dev/null)
assert_eq "standard hook enabled (default profile)" "yes" "$RESULT"

# Default profile, hook declares only strict → no
RESULT=$(node "$CHECK_ENABLED" "my-hook" "strict" 2>/dev/null)
assert_eq "strict-only hook disabled (default profile)" "no" "$RESULT"

# Minimal profile, hook declares minimal,standard,strict → yes
export TEMPLATE_HOOK_PROFILE=minimal
RESULT=$(node "$CHECK_ENABLED" "my-hook" "minimal,standard,strict" 2>/dev/null)
assert_eq "lifecycle hook enabled (minimal profile)" "yes" "$RESULT"

# Minimal profile, hook declares standard,strict → no
RESULT=$(node "$CHECK_ENABLED" "my-hook" "standard,strict" 2>/dev/null)
assert_eq "quality hook disabled (minimal profile)" "no" "$RESULT"

# Disabled hooks override
unset TEMPLATE_HOOK_PROFILE
export TEMPLATE_DISABLED_HOOKS="my-hook"
RESULT=$(node "$CHECK_ENABLED" "my-hook" "minimal,standard,strict" 2>/dev/null)
assert_eq "disabled hook returns no" "no" "$RESULT"

# Other hooks unaffected
RESULT=$(node "$CHECK_ENABLED" "other-hook" "standard,strict" 2>/dev/null)
assert_eq "non-disabled hook still yes" "yes" "$RESULT"

# ─── run-with-flags-shell.sh tests ─────────────────────────────
echo ""
echo "## run-with-flags-shell.sh dispatcher"
unset TEMPLATE_HOOK_PROFILE
unset TEMPLATE_DISABLED_HOOKS

# Create a temp test script
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << 'SCRIPT'
#!/usr/bin/env bash
echo "HOOK_RAN"
SCRIPT
chmod +x "$TEMP_SCRIPT"

# Enabled hook should run the script
RESULT=$(echo '{}' | bash "$RUN_WITH_FLAGS" "test-hook" "$TEMP_SCRIPT" "standard,strict" 2>/dev/null)
assert_eq "enabled hook executes script" "HOOK_RAN" "$RESULT"

# Disabled hook should pass stdin through
export TEMPLATE_DISABLED_HOOKS="test-hook"
RESULT=$(echo '{"test":"data"}' | bash "$RUN_WITH_FLAGS" "test-hook" "$TEMP_SCRIPT" "standard,strict" 2>/dev/null)
assert_eq "disabled hook passes stdin through" '{"test":"data"}' "$RESULT"

# Missing script should pass stdin through
unset TEMPLATE_DISABLED_HOOKS
RESULT=$(echo '{"test":"data"}' | bash "$RUN_WITH_FLAGS" "test-hook" "/nonexistent/script.sh" "standard,strict" 2>/dev/null)
assert_eq "missing script passes stdin through" '{"test":"data"}' "$RESULT"

# Extra args passthrough (for observe.sh pre/post pattern)
TEMP_ARGS_SCRIPT=$(mktemp)
cat > "$TEMP_ARGS_SCRIPT" << 'SCRIPT'
#!/usr/bin/env bash
echo "ARG:$1"
SCRIPT
chmod +x "$TEMP_ARGS_SCRIPT"

RESULT=$(echo '{}' | bash "$RUN_WITH_FLAGS" "observe" "$TEMP_ARGS_SCRIPT" "standard,strict" "pre" 2>/dev/null)
assert_eq "extra args passed to script" "ARG:pre" "$RESULT"

# Cleanup
rm -f "$TEMP_SCRIPT" "$TEMP_ARGS_SCRIPT"

# ─── Summary ────────────────────────────────────────────────────
unset TEMPLATE_HOOK_PROFILE
unset TEMPLATE_DISABLED_HOOKS

echo ""
echo "# Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
