#!/usr/bin/env bash
# Hook Profile Check — bash wrapper for hook-profiles.js
#
# Usage in any hook script:
#   source "$(dirname "$0")/lib/check-profile.sh"
#   check_hook_enabled "hook-id" || exit 0
#
# Returns 0 if the hook is enabled, 1 if disabled.
# Falls back to allowing the hook if Node.js is unavailable.

check_hook_enabled() {
  local hook_id="$1"
  local lib_dir
  lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  if command -v node &>/dev/null; then
    node -e "
      const { isHookEnabled } = require('${lib_dir}/hook-profiles.js');
      process.exit(isHookEnabled('${hook_id}') ? 0 : 1);
    " 2>/dev/null
    return $?
  fi

  # Fallback: if Node.js is unavailable, allow the hook to run
  return 0
}
