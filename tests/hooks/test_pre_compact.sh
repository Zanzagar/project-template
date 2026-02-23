#!/bin/bash
# Tests for pre-compact.sh hook
# Verifies extended state preservation: tag, TDD phase, uncommitted count, branch
#
# Usage: bash tests/hooks/test_pre_compact.sh

set +e

HOOK="$(cd "$(dirname "$0")/../.." && pwd)/.claude/hooks/pre-compact.sh"
ORIG_DIR="$(pwd)"
PASS=0
FAIL=0
TESTS_RUN=0
TMPDIR_LIST=()

# --- Helpers ---

setup_repo() {
    TEST_REPO=$(mktemp -d)
    TMPDIR_LIST+=("$TEST_REPO")
    cd "$TEST_REPO" || exit 1
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
    echo "init" > README.md
    git add README.md
    git commit -q -m "feat: initial commit"
    # Create .claude/sessions dir
    mkdir -p .claude/sessions
}

teardown() {
    cd "$ORIG_DIR" || exit 1
    [ -n "$TEST_REPO" ] && [ -d "$TEST_REPO" ] && rm -rf "$TEST_REPO"
    TEST_REPO=""
}

run_hook() {
    # Pipe a compact-related message to trigger the hook
    echo '{"user_prompt":"/compact"}' | CLAUDE_PROJECT_DIR="$(pwd)" bash "$HOOK" > /dev/null 2>&1
    echo $?
}

state_file() {
    echo "$(pwd)/.claude/sessions/pre-compact-state.md"
}

assert_eq() {
    local test_name="$1" expected="$2" actual="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ "$expected" = "$actual" ]; then
        echo "  PASS: $test_name"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $test_name (expected=$expected, actual=$actual)"
        FAIL=$((FAIL + 1))
    fi
}

assert_contains() {
    local test_name="$1" file="$2" pattern="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo "  PASS: $test_name"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $test_name (pattern '$pattern' not found in file)"
        FAIL=$((FAIL + 1))
    fi
}

assert_not_contains() {
    local test_name="$1" file="$2" pattern="$3"
    TESTS_RUN=$((TESTS_RUN + 1))
    if ! grep -q "$pattern" "$file" 2>/dev/null; then
        echo "  PASS: $test_name"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $test_name (pattern '$pattern' unexpectedly found in file)"
        FAIL=$((FAIL + 1))
    fi
}

# --- Test: State file contains Task Master Tag section (R2.1) ---

test_tag_section_present() {
    echo "=== Task Master Tag section (R2.1) ==="
    setup_repo

    run_hook
    local sf
    sf=$(state_file)

    assert_contains "state file has Tag section" "$sf" "## Task Master Tag"
    assert_contains "tag defaults to master" "$sf" "master"

    teardown
}

test_tag_from_state_file() {
    echo "=== Task Master Tag from state.json (currentTag) ==="
    setup_repo

    # Create mock .taskmaster/state.json with currentTag (current TM format)
    mkdir -p .taskmaster
    echo '{"currentTag":"feature-auth"}' > .taskmaster/state.json

    run_hook
    local sf
    sf=$(state_file)

    assert_contains "tag reads currentTag from state.json" "$sf" "feature-auth"

    teardown
}

test_tag_from_state_file_legacy() {
    echo "=== Task Master Tag from state.json (legacy activeTag) ==="
    setup_repo

    # Create mock .taskmaster/state.json with legacy activeTag field
    mkdir -p .taskmaster
    echo '{"activeTag":"bugfix-api"}' > .taskmaster/state.json

    run_hook
    local sf
    sf=$(state_file)

    assert_contains "tag reads legacy activeTag from state.json" "$sf" "bugfix-api"

    teardown
}

# --- Test: TDD Phase section (R2.2) ---

test_tdd_phase_no_tests() {
    echo "=== TDD Phase: no tests directory (R2.2) ==="
    setup_repo

    run_hook
    local sf
    sf=$(state_file)

    assert_contains "state file has TDD Phase section" "$sf" "## TDD Phase"
    assert_contains "TDD phase shows N/A when no tests" "$sf" "N/A"

    teardown
}

test_tdd_phase_with_passing_tests() {
    echo "=== TDD Phase: passing tests ==="
    setup_repo

    # Create a passing test
    mkdir -p tests
    cat > tests/test_simple.py << 'PYEOF'
def test_pass():
    assert True
PYEOF

    run_hook
    local sf
    sf=$(state_file)

    assert_contains "TDD phase shows GREEN when tests pass" "$sf" "GREEN"

    teardown
}

test_tdd_phase_with_failing_tests() {
    echo "=== TDD Phase: failing tests ==="
    setup_repo

    # Create a failing test
    mkdir -p tests
    cat > tests/test_simple.py << 'PYEOF'
def test_fail():
    assert False
PYEOF

    run_hook
    local sf
    sf=$(state_file)

    assert_contains "TDD phase shows RED when tests fail" "$sf" "RED"

    teardown
}

# --- Test: Uncommitted changes count (R2.3) ---

test_uncommitted_count_zero() {
    echo "=== Uncommitted count: clean tree (R2.3) ==="
    setup_repo

    run_hook
    local sf
    sf=$(state_file)

    assert_contains "uncommitted section shows 0 files" "$sf" "0 files"

    teardown
}

test_uncommitted_count_nonzero() {
    echo "=== Uncommitted count: dirty tree ==="
    setup_repo

    echo "new" > file1.txt
    echo "new" > file2.txt
    echo "new" > file3.txt

    run_hook
    local sf
    sf=$(state_file)

    assert_contains "uncommitted section shows 3 files" "$sf" "3 files"

    teardown
}

# --- Test: Branch name preserved (R2.4) ---

test_branch_name_feature() {
    echo "=== Branch name: feature branch (R2.4) ==="
    setup_repo

    git checkout -q -b feature/my-feature

    run_hook
    local sf
    sf=$(state_file)

    assert_contains "branch name captured" "$sf" "feature/my-feature"

    teardown
}

# --- Test: Existing state preserved (R2.5) ---

test_existing_state_preserved() {
    echo "=== Existing state preservation (R2.5) ==="
    setup_repo

    run_hook
    local sf
    sf=$(state_file)

    # Original sections still present
    assert_contains "has Active Task section" "$sf" "## Active Task"
    assert_contains "has Branch section" "$sf" "## Branch"
    assert_contains "has Uncommitted Changes section" "$sf" "## Uncommitted Changes"
    assert_contains "has Context to Preserve section" "$sf" "## Context to Preserve"
    assert_contains "has timestamp" "$sf" "Saved:"

    teardown
}

# --- Test: Hook exits 0 always ---

test_always_exits_zero() {
    echo "=== Hook always exits 0 ==="
    setup_repo

    local exit_code
    exit_code=$(run_hook)
    assert_eq "hook exits 0" "0" "$exit_code"

    teardown
}

# --- Run all tests ---

echo "================================================"
echo "  pre-compact.sh Test Suite"
echo "================================================"
echo ""

test_tag_section_present
test_tag_from_state_file
test_tag_from_state_file_legacy
test_tdd_phase_no_tests
test_tdd_phase_with_passing_tests
test_tdd_phase_with_failing_tests
test_uncommitted_count_zero
test_uncommitted_count_nonzero
test_branch_name_feature
test_existing_state_preserved
test_always_exits_zero

echo ""
echo "================================================"
echo "  Results: $PASS passed, $FAIL failed (of $TESTS_RUN)"
echo "================================================"

for d in "${TMPDIR_LIST[@]}"; do
    [ -d "$d" ] && rm -rf "$d"
done

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0
