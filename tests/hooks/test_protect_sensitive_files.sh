#!/bin/bash
# Tests for protect-sensitive-files.sh hook
# Verifies sensitive file/directory blocking and safe file allowlisting
#
# Usage: bash tests/hooks/test_protect_sensitive_files.sh
#
# Each test feeds mock JSON to the hook's stdin and verifies the exit code:
#   0 = allow the edit
#   2 = block the edit (sensitive file/directory)

set +e

HOOK="$(cd "$(dirname "$0")/../.." && pwd)/.claude/hooks/protect-sensitive-files.sh"
PASS=0
FAIL=0
TESTS_RUN=0

# --- Helpers ---

make_input() {
    local file_path="$1"
    # Produce JSON: {"tool_input": {"file_path": "/path/to/file"}}
    echo "{\"tool_input\":{\"file_path\":\"$file_path\"}}"
}

run_hook() {
    local input="$1"
    local exit_code
    echo "$input" | bash "$HOOK" > /dev/null 2>&1
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

# ====================================================================
#  Protected Files — must be BLOCKED (exit 2)
# ====================================================================

test_blocks_env() {
    echo "=== Blocks .env files ==="

    local exit_code

    exit_code=$(run_hook "$(make_input "/project/.env")")
    assert_eq "blocks .env" "2" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/.env.local")")
    assert_eq "blocks .env.local" "2" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/.env.production")")
    assert_eq "blocks .env.production" "2" "$exit_code"
}

test_blocks_credential_files() {
    echo "=== Blocks credential files ==="

    local exit_code

    exit_code=$(run_hook "$(make_input "/project/credentials.json")")
    assert_eq "blocks credentials.json" "2" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/secrets.json")")
    assert_eq "blocks secrets.json" "2" "$exit_code"
}

test_blocks_key_and_cert_files() {
    echo "=== Blocks .pem and .key files ==="

    local exit_code

    exit_code=$(run_hook "$(make_input "/project/certs/server.pem")")
    assert_eq "blocks server.pem" "2" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/ssl/ca-bundle.pem")")
    assert_eq "blocks ca-bundle.pem" "2" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/keys/private.key")")
    assert_eq "blocks private.key" "2" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/tls/domain.key")")
    assert_eq "blocks domain.key" "2" "$exit_code"
}

test_blocks_ssh_keys() {
    echo "=== Blocks SSH key files ==="

    local exit_code

    exit_code=$(run_hook "$(make_input "/home/user/.ssh/id_rsa")")
    assert_eq "blocks id_rsa" "2" "$exit_code"

    exit_code=$(run_hook "$(make_input "/home/user/.ssh/id_ed25519")")
    assert_eq "blocks id_ed25519" "2" "$exit_code"
}

# ====================================================================
#  Protected Directories — must be BLOCKED (exit 2)
# ====================================================================

test_blocks_git_directory() {
    echo "=== Blocks .git/ directory ==="

    local exit_code

    exit_code=$(run_hook "$(make_input "/project/.git/config")")
    assert_eq "blocks .git/config" "2" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/.git/hooks/pre-commit")")
    assert_eq "blocks .git/hooks/pre-commit" "2" "$exit_code"
}

test_blocks_node_modules_directory() {
    echo "=== Blocks node_modules/ directory ==="

    local exit_code

    exit_code=$(run_hook "$(make_input "/project/node_modules/lodash/index.js")")
    assert_eq "blocks node_modules/lodash/index.js" "2" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/frontend/node_modules/react/index.js")")
    assert_eq "blocks nested node_modules path" "2" "$exit_code"
}

test_blocks_pycache_directory() {
    echo "=== Blocks __pycache__/ directory ==="

    local exit_code

    exit_code=$(run_hook "$(make_input "/project/src/__pycache__/module.cpython-311.pyc")")
    assert_eq "blocks __pycache__/ file" "2" "$exit_code"
}

test_blocks_venv_directories() {
    echo "=== Blocks .venv/ and venv/ directories ==="

    local exit_code

    exit_code=$(run_hook "$(make_input "/project/.venv/lib/python3.11/site-packages/pip/__init__.py")")
    assert_eq "blocks .venv/ file" "2" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/venv/lib/python3.11/site-packages/pip/__init__.py")")
    assert_eq "blocks venv/ file" "2" "$exit_code"
}

# ====================================================================
#  Allowed Files — must be ALLOWED (exit 0)
# ====================================================================

test_allows_normal_source_files() {
    echo "=== Allows normal source files ==="

    local exit_code

    exit_code=$(run_hook "$(make_input "/project/src/main.py")")
    assert_eq "allows src/main.py" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/src/api/routes.py")")
    assert_eq "allows src/api/routes.py" "0" "$exit_code"
}

test_allows_test_files() {
    echo "=== Allows test files ==="

    local exit_code

    exit_code=$(run_hook "$(make_input "/project/tests/test_foo.py")")
    assert_eq "allows tests/test_foo.py" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/tests/unit/test_auth.py")")
    assert_eq "allows tests/unit/test_auth.py" "0" "$exit_code"
}

test_allows_safe_config_files() {
    echo "=== Allows non-sensitive config files ==="

    local exit_code

    exit_code=$(run_hook "$(make_input "/project/config.toml")")
    assert_eq "allows config.toml" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/pyproject.toml")")
    assert_eq "allows pyproject.toml" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/setup.cfg")")
    assert_eq "allows setup.cfg" "0" "$exit_code"
}

test_allows_env_sample_files() {
    echo "=== Allows .env.sample and .env.example ==="

    local exit_code

    exit_code=$(run_hook "$(make_input "/project/.env.sample")")
    assert_eq "allows .env.sample" "0" "$exit_code"

    exit_code=$(run_hook "$(make_input "/project/.env.example")")
    assert_eq "allows .env.example" "0" "$exit_code"
}

# ====================================================================
#  Edge Cases — graceful handling
# ====================================================================

test_handles_empty_file_path() {
    echo "=== Handles empty/missing file_path ==="

    local exit_code

    # Empty file_path field
    exit_code=$(run_hook '{"tool_input":{"file_path":""}}')
    assert_eq "allows empty file_path string" "0" "$exit_code"

    # Missing file_path field entirely
    exit_code=$(run_hook '{"tool_input":{"other_field":"value"}}')
    assert_eq "allows missing file_path field" "0" "$exit_code"

    # Empty tool_input
    exit_code=$(run_hook '{"tool_input":{}}')
    assert_eq "allows empty tool_input" "0" "$exit_code"
}

test_handles_malformed_json() {
    echo "=== Handles malformed JSON ==="

    local exit_code

    # Completely invalid JSON
    exit_code=$(run_hook 'not json at all')
    assert_eq "allows (graceful) on malformed JSON" "0" "$exit_code"

    # Truncated JSON
    exit_code=$(run_hook '{"tool_input":{"file_path":')
    assert_eq "allows (graceful) on truncated JSON" "0" "$exit_code"

    # Empty input
    exit_code=$(run_hook '')
    assert_eq "allows (graceful) on empty input" "0" "$exit_code"
}

# ====================================================================
#  Run all tests
# ====================================================================

echo "================================================"
echo "  protect-sensitive-files.sh Test Suite"
echo "================================================"
echo ""

# Protected files
test_blocks_env
test_blocks_credential_files
test_blocks_key_and_cert_files
test_blocks_ssh_keys

# Protected directories
test_blocks_git_directory
test_blocks_node_modules_directory
test_blocks_pycache_directory
test_blocks_venv_directories

# Allowed files
test_allows_normal_source_files
test_allows_test_files
test_allows_safe_config_files
test_allows_env_sample_files

# Edge cases
test_handles_empty_file_path
test_handles_malformed_json

echo ""
echo "================================================"
echo "  Results: $PASS passed, $FAIL failed (of $TESTS_RUN)"
echo "================================================"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0
