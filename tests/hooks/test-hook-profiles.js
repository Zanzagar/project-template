'use strict';

const { describe, it, beforeEach, afterEach } = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

// Path to the module under test (adapted from ECC's hook-flags.js)
const MODULE_PATH = path.resolve(__dirname, '../../.claude/hooks/lib/hook-flags.js');

// Helper: fresh-require the module (clears cache so env var changes take effect)
function loadModule() {
  delete require.cache[MODULE_PATH];
  return require(MODULE_PATH);
}

// Save and restore env vars between tests
let savedEnv;

beforeEach(() => {
  savedEnv = {
    TEMPLATE_HOOK_PROFILE: process.env.TEMPLATE_HOOK_PROFILE,
    TEMPLATE_DISABLED_HOOKS: process.env.TEMPLATE_DISABLED_HOOKS,
  };
  delete process.env.TEMPLATE_HOOK_PROFILE;
  delete process.env.TEMPLATE_DISABLED_HOOKS;
});

afterEach(() => {
  for (const [key, val] of Object.entries(savedEnv)) {
    if (val !== undefined) process.env[key] = val;
    else delete process.env[key];
  }
});

// ─── Core exports ──────────────────────────────────────────────

describe('Module exports', () => {
  it('exports all expected functions and constants', () => {
    const mod = loadModule();
    assert.ok(mod.VALID_PROFILES instanceof Set);
    assert.equal(typeof mod.normalizeId, 'function');
    assert.equal(typeof mod.getHookProfile, 'function');
    assert.equal(typeof mod.getDisabledHookIds, 'function');
    assert.equal(typeof mod.parseProfiles, 'function');
    assert.equal(typeof mod.isHookEnabled, 'function');
  });

  it('VALID_PROFILES contains minimal, standard, strict', () => {
    const { VALID_PROFILES } = loadModule();
    assert.ok(VALID_PROFILES.has('minimal'));
    assert.ok(VALID_PROFILES.has('standard'));
    assert.ok(VALID_PROFILES.has('strict'));
    assert.equal(VALID_PROFILES.size, 3);
  });
});

// ─── normalizeId() ─────────────────────────────────────────────

describe('normalizeId()', () => {
  it('trims and lowercases', () => {
    const { normalizeId } = loadModule();
    assert.equal(normalizeId('  Session-Init  '), 'session-init');
  });

  it('handles null/undefined gracefully', () => {
    const { normalizeId } = loadModule();
    assert.equal(normalizeId(null), '');
    assert.equal(normalizeId(undefined), '');
    assert.equal(normalizeId(''), '');
  });
});

// ─── getHookProfile() ──────────────────────────────────────────

describe('getHookProfile()', () => {
  it('returns "standard" when no env var is set', () => {
    const { getHookProfile } = loadModule();
    assert.equal(getHookProfile(), 'standard');
  });

  it('returns the env var value when valid', () => {
    process.env.TEMPLATE_HOOK_PROFILE = 'minimal';
    const { getHookProfile } = loadModule();
    assert.equal(getHookProfile(), 'minimal');
  });

  it('returns "standard" for unknown profile names', () => {
    process.env.TEMPLATE_HOOK_PROFILE = 'turbo';
    const { getHookProfile } = loadModule();
    assert.equal(getHookProfile(), 'standard');
  });

  it('normalizes case and whitespace', () => {
    process.env.TEMPLATE_HOOK_PROFILE = '  STRICT  ';
    const { getHookProfile } = loadModule();
    assert.equal(getHookProfile(), 'strict');
  });
});

// ─── getDisabledHookIds() ──────────────────────────────────────

describe('getDisabledHookIds()', () => {
  it('returns empty set when no env var is set', () => {
    const { getDisabledHookIds } = loadModule();
    const result = getDisabledHookIds();
    assert.ok(result instanceof Set);
    assert.equal(result.size, 0);
  });

  it('parses comma-separated hook IDs', () => {
    process.env.TEMPLATE_DISABLED_HOOKS = 'observe,session-init';
    const { getDisabledHookIds } = loadModule();
    const result = getDisabledHookIds();
    assert.ok(result.has('observe'));
    assert.ok(result.has('session-init'));
    assert.equal(result.size, 2);
  });

  it('trims whitespace and normalizes case', () => {
    process.env.TEMPLATE_DISABLED_HOOKS = ' Observe , SESSION-INIT ';
    const { getDisabledHookIds } = loadModule();
    const result = getDisabledHookIds();
    assert.ok(result.has('observe'));
    assert.ok(result.has('session-init'));
  });

  it('handles empty string', () => {
    process.env.TEMPLATE_DISABLED_HOOKS = '';
    const { getDisabledHookIds } = loadModule();
    assert.equal(getDisabledHookIds().size, 0);
  });
});

// ─── parseProfiles() ───────────────────────────────────────────

describe('parseProfiles()', () => {
  it('parses CSV string into profile array', () => {
    const { parseProfiles } = loadModule();
    assert.deepEqual(parseProfiles('minimal,standard'), ['minimal', 'standard']);
  });

  it('parses array input', () => {
    const { parseProfiles } = loadModule();
    assert.deepEqual(parseProfiles(['minimal', 'strict']), ['minimal', 'strict']);
  });

  it('falls back to default when null/undefined', () => {
    const { parseProfiles } = loadModule();
    assert.deepEqual(parseProfiles(null), ['standard', 'strict']);
    assert.deepEqual(parseProfiles(undefined), ['standard', 'strict']);
  });

  it('falls back to default for invalid profile names', () => {
    const { parseProfiles } = loadModule();
    assert.deepEqual(parseProfiles('turbo,mega'), ['standard', 'strict']);
  });

  it('filters out invalid profiles from mixed input', () => {
    const { parseProfiles } = loadModule();
    assert.deepEqual(parseProfiles('minimal,turbo,strict'), ['minimal', 'strict']);
  });

  it('accepts custom fallback', () => {
    const { parseProfiles } = loadModule();
    assert.deepEqual(parseProfiles(null, ['minimal']), ['minimal']);
  });
});

// ─── isHookEnabled() ───────────────────────────────────────────

describe('isHookEnabled()', () => {
  // ─── Per-hook profile declaration (ECC architecture) ───

  describe('with default profile (standard)', () => {
    it('returns true when hook declares standard in its profiles', () => {
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('my-hook', { profiles: 'standard,strict' }), true);
      assert.equal(isHookEnabled('my-hook', { profiles: 'minimal,standard,strict' }), true);
    });

    it('returns false when hook only declares strict', () => {
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('my-hook', { profiles: 'strict' }), false);
    });

    it('returns false when hook only declares minimal', () => {
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('my-hook', { profiles: 'minimal' }), false);
    });
  });

  describe('with TEMPLATE_HOOK_PROFILE=minimal', () => {
    it('returns true for hooks declaring minimal', () => {
      process.env.TEMPLATE_HOOK_PROFILE = 'minimal';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('my-hook', { profiles: 'minimal,standard,strict' }), true);
    });

    it('returns false for hooks declaring only standard,strict', () => {
      process.env.TEMPLATE_HOOK_PROFILE = 'minimal';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('my-hook', { profiles: 'standard,strict' }), false);
    });
  });

  describe('with TEMPLATE_HOOK_PROFILE=strict', () => {
    it('returns true for hooks declaring strict', () => {
      process.env.TEMPLATE_HOOK_PROFILE = 'strict';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('my-hook', { profiles: 'strict' }), true);
      assert.equal(isHookEnabled('my-hook', { profiles: 'standard,strict' }), true);
    });

    it('returns false for hooks declaring only minimal', () => {
      process.env.TEMPLATE_HOOK_PROFILE = 'strict';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('my-hook', { profiles: 'minimal' }), false);
    });
  });

  // ─── Fallback behavior ───

  describe('fallback when no profiles declared', () => {
    it('defaults to standard,strict when profiles option is omitted', () => {
      const { isHookEnabled } = loadModule();
      // Default profile is standard, default allowed is [standard, strict]
      assert.equal(isHookEnabled('my-hook'), true);
    });

    it('returns false with minimal profile when no profiles declared', () => {
      process.env.TEMPLATE_HOOK_PROFILE = 'minimal';
      const { isHookEnabled } = loadModule();
      // Default allowed is [standard, strict], minimal not in that set
      assert.equal(isHookEnabled('my-hook'), false);
    });
  });

  // ─── TEMPLATE_DISABLED_HOOKS override ───

  describe('with TEMPLATE_DISABLED_HOOKS', () => {
    it('disables a hook regardless of profile match', () => {
      process.env.TEMPLATE_DISABLED_HOOKS = 'my-hook';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('my-hook', { profiles: 'minimal,standard,strict' }), false);
    });

    it('disables multiple hooks', () => {
      process.env.TEMPLATE_DISABLED_HOOKS = 'hook-a,hook-b';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('hook-a', { profiles: 'standard,strict' }), false);
      assert.equal(isHookEnabled('hook-b', { profiles: 'standard,strict' }), false);
      assert.equal(isHookEnabled('hook-c', { profiles: 'standard,strict' }), true);
    });

    it('overrides even strict profile', () => {
      process.env.TEMPLATE_HOOK_PROFILE = 'strict';
      process.env.TEMPLATE_DISABLED_HOOKS = 'my-hook';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('my-hook', { profiles: 'strict' }), false);
    });

    it('handles whitespace in comma-separated list', () => {
      process.env.TEMPLATE_DISABLED_HOOKS = ' hook-a , hook-b ';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('hook-a', { profiles: 'standard,strict' }), false);
      assert.equal(isHookEnabled('hook-b', { profiles: 'standard,strict' }), false);
    });
  });

  // ─── Edge cases ───

  describe('edge cases', () => {
    it('returns true for empty hookId', () => {
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled(''), true);
      assert.equal(isHookEnabled(null), true);
    });

    it('normalizes hookId case', () => {
      process.env.TEMPLATE_DISABLED_HOOKS = 'my-hook';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('MY-HOOK', { profiles: 'standard,strict' }), false);
    });
  });
});

// ─── Template-specific profile mapping ─────────────────────────
// These tests verify the actual profile assignments for our template's hooks,
// as they would appear in settings.json run-with-flags arguments.

describe('Template hook profile assignments', () => {
  const LIFECYCLE_HOOKS = [
    'session-init', 'project-index', 'pre-commit-check',
    'protect-sensitive-files', 'pre-compact', 'session-end',
    'pattern-extraction',
  ];
  const QUALITY_HOOKS = [
    'post-edit-format', 'console-log-audit', 'suggest-compact',
    'build-analysis', 'pr-url-extract', 'observe', 'session-summary',
  ];
  const ENFORCEMENT_HOOKS = [
    'typescript-check', 'doc-file-blocker', 'dev-server-blocker',
    'long-running-tmux-hint',
  ];

  it('lifecycle hooks run at all profiles', () => {
    const { isHookEnabled } = loadModule();
    for (const profile of ['minimal', 'standard', 'strict']) {
      process.env.TEMPLATE_HOOK_PROFILE = profile;
      for (const hookId of LIFECYCLE_HOOKS) {
        assert.equal(
          isHookEnabled(hookId, { profiles: 'minimal,standard,strict' }),
          true,
          `${hookId} should be enabled at ${profile}`
        );
      }
    }
  });

  it('quality hooks run at standard and strict only', () => {
    const { isHookEnabled } = loadModule();
    for (const hookId of QUALITY_HOOKS) {
      process.env.TEMPLATE_HOOK_PROFILE = 'minimal';
      assert.equal(
        isHookEnabled(hookId, { profiles: 'standard,strict' }),
        false,
        `${hookId} should be disabled at minimal`
      );
      process.env.TEMPLATE_HOOK_PROFILE = 'standard';
      assert.equal(
        isHookEnabled(hookId, { profiles: 'standard,strict' }),
        true,
        `${hookId} should be enabled at standard`
      );
    }
  });

  it('enforcement hooks run at strict only', () => {
    const { isHookEnabled } = loadModule();
    for (const hookId of ENFORCEMENT_HOOKS) {
      process.env.TEMPLATE_HOOK_PROFILE = 'standard';
      assert.equal(
        isHookEnabled(hookId, { profiles: 'strict' }),
        false,
        `${hookId} should be disabled at standard`
      );
      process.env.TEMPLATE_HOOK_PROFILE = 'strict';
      assert.equal(
        isHookEnabled(hookId, { profiles: 'strict' }),
        true,
        `${hookId} should be enabled at strict`
      );
    }
  });
});
