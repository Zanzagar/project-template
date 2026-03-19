#!/usr/bin/env bash
# Tests for .claude/hooks/lib/check-profile.sh
# Run: bash tests/hooks/test-check-profile.sh

set +e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
CHECK_PROFILE="$PROJECT_ROOT/.claude/hooks/lib/check-profile.sh"

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

echo "# check-profile.sh tests"
echo ""

# ─── Test: script exists and is sourceable ──────────────────
echo "## Sourceable"
if [ -f "$CHECK_PROFILE" ]; then
  assert_eq "check-profile.sh exists" "0" "0"
else
  assert_eq "check-profile.sh exists" "exists" "missing"
fi

# ─── Test: enabled hook returns 0 (success) ────────────────
echo "## Hook enabled under standard profile"
unset TEMPLATE_HOOK_PROFILE
unset TEMPLATE_DISABLED_HOOKS

(
  source "$CHECK_PROFILE"
  check_hook_enabled "session-init"
)
assert_eq "session-init enabled (standard)" "0" "$?"

(
  source "$CHECK_PROFILE"
  check_hook_enabled "observe"
)
assert_eq "observe enabled (standard)" "0" "$?"

# ─── Test: disabled hook returns 1 (skip) ──────────────────
echo "## Hook disabled under minimal profile"
export TEMPLATE_HOOK_PROFILE=minimal

(
  source "$CHECK_PROFILE"
  check_hook_enabled "observe"
)
assert_eq "observe disabled (minimal)" "1" "$?"

(
  source "$CHECK_PROFILE"
  check_hook_enabled "session-init"
)
assert_eq "session-init enabled (minimal)" "0" "$?"

# ─── Test: TEMPLATE_DISABLED_HOOKS override ─────────────────
echo "## Disabled hooks override"
unset TEMPLATE_HOOK_PROFILE
export TEMPLATE_DISABLED_HOOKS="session-init"

(
  source "$CHECK_PROFILE"
  check_hook_enabled "session-init"
)
assert_eq "session-init disabled via override" "1" "$?"

(
  source "$CHECK_PROFILE"
  check_hook_enabled "observe"
)
assert_eq "observe still enabled" "0" "$?"

# ─── Test: strict profile enables strict-only hooks ─────────
echo "## Strict profile"
export TEMPLATE_HOOK_PROFILE=strict
unset TEMPLATE_DISABLED_HOOKS

(
  source "$CHECK_PROFILE"
  check_hook_enabled "file-size-guard"
)
assert_eq "file-size-guard enabled (strict)" "0" "$?"

# ─── Summary ────────────────────────────────────────────────
unset TEMPLATE_HOOK_PROFILE
unset TEMPLATE_DISABLED_HOOKS

echo ""
echo "# Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
