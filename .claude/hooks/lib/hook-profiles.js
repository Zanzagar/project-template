'use strict';

// Hook Profile System — runtime hook toggling via environment variables.
//
// Env vars:
//   TEMPLATE_HOOK_PROFILE    — "minimal" | "standard" | "strict" (default: "standard")
//   TEMPLATE_DISABLED_HOOKS  — comma-separated hook IDs to force-disable

// ─── Profile Definitions ───────────────────────────────────────
//
// Profiles are strictly hierarchical: minimal < standard < strict.
// Each tier includes all hooks from the tier below it.

const MINIMAL = [
  'session-init',
  'project-index',
  'pre-commit-check',
  'protect-sensitive-files',
  'pre-compact',
  'session-end',
  'pattern-extraction',
];

const STANDARD_ADDITIONS = [
  'post-edit-format',
  'console-log-audit',
  'suggest-compact',
  'build-analysis',
  'pr-url-extract',
  'observe',
  'session-summary',
];

const STRICT_ADDITIONS = [
  'file-size-guard',
  'quality-gate',
  'cost-tracker',
  'typescript-check',
  'doc-file-blocker',
  'dev-server-blocker',
  'long-running-tmux-hint',
];

const PROFILES = {
  minimal: MINIMAL,
  standard: [...MINIMAL, ...STANDARD_ADDITIONS],
  strict: [...MINIMAL, ...STANDARD_ADDITIONS, ...STRICT_ADDITIONS],
};

const VALID_PROFILES = new Set(Object.keys(PROFILES));

// ─── Public API ────────────────────────────────────────────────

/**
 * Returns the active profile name, validated against known profiles.
 * Falls back to 'standard' for unknown values.
 */
function getProfile() {
  const raw = process.env.TEMPLATE_HOOK_PROFILE || 'standard';
  return VALID_PROFILES.has(raw) ? raw : 'standard';
}

/**
 * Returns the set of disabled hook IDs from TEMPLATE_DISABLED_HOOKS env var.
 */
function getDisabledHooks() {
  const raw = process.env.TEMPLATE_DISABLED_HOOKS || '';
  return new Set(
    raw.split(',').map(s => s.trim()).filter(Boolean)
  );
}

/**
 * Check whether a specific hook is enabled under the current profile and overrides.
 *
 * @param {string} hookId - The hook identifier (e.g., 'session-init', 'observe')
 * @param {object} [options]
 * @param {object} [options.profiles] - Custom profile definitions (for testing)
 * @returns {boolean}
 */
function isHookEnabled(hookId, options = {}) {
  const profiles = options.profiles || PROFILES;
  const profileName = getProfile();
  const enabledHooks = profiles[profileName] || profiles.standard || [];
  const disabledHooks = getDisabledHooks();

  if (disabledHooks.has(hookId)) return false;
  return enabledHooks.includes(hookId);
}

/**
 * Returns the list of all enabled hook IDs for the current profile,
 * after applying TEMPLATE_DISABLED_HOOKS exclusions.
 *
 * @returns {string[]}
 */
function getEnabledHooks() {
  const profileName = getProfile();
  const enabledHooks = PROFILES[profileName] || PROFILES.standard;
  const disabledHooks = getDisabledHooks();
  return enabledHooks.filter(id => !disabledHooks.has(id));
}

module.exports = {
  PROFILES,
  isHookEnabled,
  getProfile,
  getEnabledHooks,
};
