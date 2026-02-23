#!/bin/bash
# Tests for pre-commit-check.sh hook
# Verifies branch protection, commit format validation, skip variables, and task warning
#
# Usage: bash tests/hooks/test_pre_commit_check.sh
#
# Each test sets up a temporary git repo, feeds mock JSON to the hook's stdin,
# and verifies the exit code (0=allow, 1=warn, 2=block).

set +e

HOOK="$(cd "$(dirname "$0")/../.." && pwd)/.claude/hooks/pre-commit-check.sh"
ORIG_DIR="$(pwd)"
PASS=0
FAIL=0
TESTS_RUN=0
TMPDIR_LIST=()

# --- Helpers ---

make_input() {
    local cmd="$1"
    # Escape inner double quotes for valid JSON
    local escaped="${cmd//\"/\\\"}"
    echo "{\"tool_input\":{\"command\":\"$escaped\"}}"
}

setup_repo() {
    # Create temp repo and cd into it (runs in main shell, not subshell)
    TEST_REPO=$(mktemp -d)
    TMPDIR_LIST+=("$TEST_REPO")
    cd "$TEST_REPO" || exit 1
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    echo "init" > README.md
    git add README.md
    git commit -q -m "feat: initial commit"
}

teardown() {
    cd "$ORIG_DIR" || exit 1
    if [ -n "$TEST_REPO" ] && [ -d "$TEST_REPO" ]; then
        rm -rf "$TEST_REPO"
    fi
    TEST_REPO=""
}

run_hook() {
    local input="$1"
    shift
    # Any additional env vars passed as KEY=VALUE arguments
    local exit_code
    echo "$input" | CLAUDE_PROJECT_DIR="$(pwd)" "$@" bash "$HOOK" > /dev/null 2>&1
    exit_code=$?
    echo "$exit_code"
}

run_hook_with_env() {
    # Run hook with extra environment variables
    local input="$1"
    shift
    local exit_code
    echo "$input" | CLAUDE_PROJECT_DIR="$(pwd)" env "$@" bash "$HOOK" > /dev/null 2>&1
    exit_code=$?
    echo "$exit_code"
}

assert_eq() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$expected" = "$actual" ]; then
        echo "  PASS: $test_name"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $test_name (expected=$expected, actual=$actual)"
        FAIL=$((FAIL + 1))
    fi
}

# --- Test: Non-commit commands pass through ---

test_non_commit_passthrough() {
    echo "=== Non-commit passthrough ==="
    setup_repo

    local exit_code
    exit_code=$(run_hook "$(make_input "git status")")
    assert_eq "git status passes through" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "git push origin main")")
    assert_eq "git push passes through" "0" "$exit_code"

    teardown
}

# --- Test: Branch protection (R1.2) ---

test_branch_protection_blocks_main() {
    echo "=== Branch protection: blocks main ==="
    setup_repo

    local exit_code
    exit_code=$(run_hook "$(make_input "git commit -m \"feat: test\"")")
    assert_eq "commit on main is BLOCKED" "2" "$exit_code"

    teardown
}

test_branch_protection_allows_feature() {
    echo "=== Branch protection: allows feature branch ==="
    setup_repo

    git checkout -q -b feature/test
    echo "change" >> README.md
    git add README.md

    local exit_code
    exit_code=$(run_hook "$(make_input "git commit -m \"feat: test feature\"")")
    assert_eq "commit on feature branch is ALLOWED" "0" "$exit_code"

    teardown
}

test_branch_protection_skip_variable() {
    echo "=== Branch protection: SKIP_BRANCH_CHECK ==="
    setup_repo

    local exit_code
    exit_code=$(run_hook_with_env "$(make_input "git commit -m \"feat: test\"")" "SKIP_BRANCH_CHECK=1")
    assert_eq "SKIP_BRANCH_CHECK=1 allows commit on main" "0" "$exit_code"

    teardown
}

# --- Test: Conventional commit format (R1.1) ---

test_commit_format_blocks_bad_message() {
    echo "=== Commit format: blocks bad message ==="
    setup_repo

    git checkout -q -b feature/test
    echo "change" >> README.md
    git add README.md

    local exit_code
    exit_code=$(run_hook "$(make_input "git commit -m \"stuff\"")")
    assert_eq "bad message 'stuff' is BLOCKED" "2" "$exit_code"

    exit_code=$(run_hook "$(make_input "git commit -m \"fix\"")")
    assert_eq "type-only message 'fix' is BLOCKED" "2" "$exit_code"

    exit_code=$(run_hook "$(make_input "git commit -m \"Fixed the thing\"")")
    assert_eq "non-conventional 'Fixed the thing' is BLOCKED" "2" "$exit_code"

    teardown
}

test_commit_format_allows_good_message() {
    echo "=== Commit format: allows good messages ==="
    setup_repo

    git checkout -q -b feature/test
    echo "change" >> README.md
    git add README.md

    local exit_code
    exit_code=$(run_hook "$(make_input "git commit -m \"feat: add new feature\"")")
    assert_eq "'feat: add new feature' is ALLOWED" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "git commit -m \"fix: resolve null pointer\"")")
    assert_eq "'fix: resolve null pointer' is ALLOWED" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "git commit -m \"fix(api): handle timeout\"")")
    assert_eq "'fix(api): handle timeout' is ALLOWED" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "git commit -m \"docs: update README\"")")
    assert_eq "'docs: update README' is ALLOWED" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "git commit -m \"chore: update deps\"")")
    assert_eq "'chore: update deps' is ALLOWED" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "git commit -m \"refactor: extract helper\"")")
    assert_eq "'refactor: extract helper' is ALLOWED" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "git commit -m \"test: add unit tests\"")")
    assert_eq "'test: add unit tests' is ALLOWED" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "git commit -m \"perf: optimize query\"")")
    assert_eq "'perf: optimize query' is ALLOWED" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "git commit -m \"ci: add workflow\"")")
    assert_eq "'ci: add workflow' is ALLOWED" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "git commit -m \"build: update config\"")")
    assert_eq "'build: update config' is ALLOWED" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "git commit -m \"revert: undo change\"")")
    assert_eq "'revert: undo change' is ALLOWED" "0" "$exit_code"

    teardown
}

test_commit_format_skip_variable() {
    echo "=== Commit format: SKIP_COMMIT_FORMAT ==="
    setup_repo

    git checkout -q -b feature/test
    echo "change" >> README.md
    git add README.md

    local exit_code
    exit_code=$(run_hook_with_env "$(make_input "git commit -m \"stuff\"")" "SKIP_COMMIT_FORMAT=1")
    assert_eq "SKIP_COMMIT_FORMAT=1 allows bad message" "0" "$exit_code"

    teardown
}

# --- Test: Existing checks preserved with skip vars (R1.4, R1.5) ---

test_existing_lint_skip() {
    echo "=== Existing checks: SKIP_LINT and SKIP_TESTS ==="
    setup_repo

    git checkout -q -b feature/test
    mkdir -p src
    echo "import os,sys" > src/bad_code.py
    git add .

    local exit_code
    exit_code=$(run_hook_with_env "$(make_input "git commit -m \"feat: add code\"")" "SKIP_LINT=1" "SKIP_TESTS=1")
    assert_eq "SKIP_LINT=1 + SKIP_TESTS=1 skips both checks" "0" "$exit_code"

    teardown
}

# --- Test: Heredoc/complex commit message ---

test_commit_format_heredoc() {
    echo "=== Commit format: heredoc/complex message ==="
    setup_repo

    git checkout -q -b feature/test
    echo "change" >> README.md
    git add README.md

    # When message can't be extracted (no -m flag), hook should skip format check gracefully
    # Use SKIP_LINT/SKIP_TESTS to isolate format validation behavior
    local exit_code
    exit_code=$(run_hook_with_env "$(make_input "git commit --file /tmp/msg.txt")" "SKIP_LINT=1" "SKIP_TESTS=1")
    assert_eq "commit with --file (no -m) passes gracefully" "0" "$exit_code"

    teardown
}

# --- Run all tests ---

echo "================================================"
echo "  pre-commit-check.sh Test Suite"
echo "================================================"
echo ""

test_non_commit_passthrough
test_branch_protection_blocks_main
test_branch_protection_allows_feature
test_branch_protection_skip_variable
test_commit_format_blocks_bad_message
test_commit_format_allows_good_message
test_commit_format_skip_variable
test_existing_lint_skip
test_commit_format_heredoc

echo ""
echo "================================================"
echo "  Results: $PASS passed, $FAIL failed (of $TESTS_RUN)"
echo "================================================"

# Cleanup any remaining temp dirs
for d in "${TMPDIR_LIST[@]}"; do
    [ -d "$d" ] && rm -rf "$d"
done

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0
