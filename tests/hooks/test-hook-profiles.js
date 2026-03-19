'use strict';

const { describe, it, beforeEach, afterEach } = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');

// Path to the module under test
const MODULE_PATH = path.resolve(__dirname, '../../.claude/hooks/lib/hook-profiles.js');

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
  if (savedEnv.TEMPLATE_HOOK_PROFILE !== undefined) {
    process.env.TEMPLATE_HOOK_PROFILE = savedEnv.TEMPLATE_HOOK_PROFILE;
  } else {
    delete process.env.TEMPLATE_HOOK_PROFILE;
  }
  if (savedEnv.TEMPLATE_DISABLED_HOOKS !== undefined) {
    process.env.TEMPLATE_DISABLED_HOOKS = savedEnv.TEMPLATE_DISABLED_HOOKS;
  } else {
    delete process.env.TEMPLATE_DISABLED_HOOKS;
  }
});

// ─── Profile Definitions ───────────────────────────────────────

describe('Profile definitions', () => {
  it('exports PROFILES object with minimal, standard, and strict keys', () => {
    const { PROFILES } = loadModule();
    assert.ok(PROFILES, 'PROFILES should be exported');
    assert.ok(Array.isArray(PROFILES.minimal), 'minimal should be an array');
    assert.ok(Array.isArray(PROFILES.standard), 'standard should be an array');
    assert.ok(Array.isArray(PROFILES.strict), 'strict should be an array');
  });

  it('minimal profile contains exactly the 7 lifecycle + safety hooks', () => {
    const { PROFILES } = loadModule();
    const expected = [
      'session-init',
      'project-index',
      'pre-commit-check',
      'protect-sensitive-files',
      'pre-compact',
      'session-end',
      'pattern-extraction',
    ];
    for (const hookId of expected) {
      assert.ok(
        PROFILES.minimal.includes(hookId),
        `minimal should include '${hookId}'`
      );
    }
    assert.equal(PROFILES.minimal.length, expected.length,
      'minimal should have exactly 7 hooks');
  });

  it('standard profile includes all of minimal plus quality hooks', () => {
    const { PROFILES } = loadModule();
    // standard must be a superset of minimal
    for (const hookId of PROFILES.minimal) {
      assert.ok(
        PROFILES.standard.includes(hookId),
        `standard should include minimal hook '${hookId}'`
      );
    }
    // standard adds these specific hooks
    const standardAdditions = [
      'post-edit-format',
      'console-log-audit',
      'suggest-compact',
      'build-analysis',
      'pr-url-extract',
      'observe',
      'session-summary',
    ];
    for (const hookId of standardAdditions) {
      assert.ok(
        PROFILES.standard.includes(hookId),
        `standard should include '${hookId}'`
      );
    }
  });

  it('strict profile includes all of standard plus enforcement hooks', () => {
    const { PROFILES } = loadModule();
    // strict must be a superset of standard
    for (const hookId of PROFILES.standard) {
      assert.ok(
        PROFILES.strict.includes(hookId),
        `strict should include standard hook '${hookId}'`
      );
    }
    // strict adds these specific hooks
    const strictAdditions = [
      'file-size-guard',
      'quality-gate',
      'cost-tracker',
      'typescript-check',
      'doc-file-blocker',
      'dev-server-blocker',
      'long-running-tmux-hint',
    ];
    for (const hookId of strictAdditions) {
      assert.ok(
        PROFILES.strict.includes(hookId),
        `strict should include '${hookId}'`
      );
    }
  });

  it('profiles are strictly hierarchical: minimal < standard < strict', () => {
    const { PROFILES } = loadModule();
    assert.ok(PROFILES.minimal.length < PROFILES.standard.length,
      'standard should have more hooks than minimal');
    assert.ok(PROFILES.standard.length < PROFILES.strict.length,
      'strict should have more hooks than standard');
  });
});

// ─── isHookEnabled() ───────────────────────────────────────────

describe('isHookEnabled()', () => {
  it('is exported as a function', () => {
    const { isHookEnabled } = loadModule();
    assert.equal(typeof isHookEnabled, 'function');
  });

  // ─── Default profile (standard) ───

  describe('with default profile (no env var set)', () => {
    it('returns true for hooks in the standard profile', () => {
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('session-init'), true);
      assert.equal(isHookEnabled('post-edit-format'), true);
      assert.equal(isHookEnabled('observe'), true);
    });

    it('returns false for hooks only in strict profile', () => {
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('file-size-guard'), false);
      assert.equal(isHookEnabled('quality-gate'), false);
      assert.equal(isHookEnabled('cost-tracker'), false);
    });

    it('returns false for unknown hook IDs', () => {
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('nonexistent-hook'), false);
      assert.equal(isHookEnabled(''), false);
    });
  });

  // ─── Explicit profile via env var ───

  describe('with TEMPLATE_HOOK_PROFILE=minimal', () => {
    it('returns true for minimal hooks only', () => {
      process.env.TEMPLATE_HOOK_PROFILE = 'minimal';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('session-init'), true);
      assert.equal(isHookEnabled('pre-commit-check'), true);
      assert.equal(isHookEnabled('protect-sensitive-files'), true);
    });

    it('returns false for standard-only hooks', () => {
      process.env.TEMPLATE_HOOK_PROFILE = 'minimal';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('post-edit-format'), false);
      assert.equal(isHookEnabled('console-log-audit'), false);
      assert.equal(isHookEnabled('observe'), false);
    });
  });

  describe('with TEMPLATE_HOOK_PROFILE=strict', () => {
    it('returns true for all hooks including strict-only', () => {
      process.env.TEMPLATE_HOOK_PROFILE = 'strict';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('session-init'), true);
      assert.equal(isHookEnabled('post-edit-format'), true);
      assert.equal(isHookEnabled('file-size-guard'), true);
      assert.equal(isHookEnabled('quality-gate'), true);
      assert.equal(isHookEnabled('typescript-check'), true);
    });
  });

  describe('with unknown profile name', () => {
    it('falls back to standard profile', () => {
      process.env.TEMPLATE_HOOK_PROFILE = 'nonexistent';
      const { isHookEnabled } = loadModule();
      // Should behave like standard
      assert.equal(isHookEnabled('session-init'), true);
      assert.equal(isHookEnabled('post-edit-format'), true);
      assert.equal(isHookEnabled('file-size-guard'), false);
    });
  });

  // ─── TEMPLATE_DISABLED_HOOKS override ───

  describe('with TEMPLATE_DISABLED_HOOKS', () => {
    it('disables a single hook that would otherwise be enabled', () => {
      process.env.TEMPLATE_DISABLED_HOOKS = 'observe';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('observe'), false);
      // Other standard hooks still enabled
      assert.equal(isHookEnabled('session-init'), true);
      assert.equal(isHookEnabled('post-edit-format'), true);
    });

    it('disables multiple comma-separated hooks', () => {
      process.env.TEMPLATE_DISABLED_HOOKS = 'observe,console-log-audit,build-analysis';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('observe'), false);
      assert.equal(isHookEnabled('console-log-audit'), false);
      assert.equal(isHookEnabled('build-analysis'), false);
      // Other hooks unaffected
      assert.equal(isHookEnabled('session-init'), true);
    });

    it('handles whitespace in comma-separated list', () => {
      process.env.TEMPLATE_DISABLED_HOOKS = ' observe , console-log-audit ';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('observe'), false);
      assert.equal(isHookEnabled('console-log-audit'), false);
    });

    it('handles empty string gracefully', () => {
      process.env.TEMPLATE_DISABLED_HOOKS = '';
      const { isHookEnabled } = loadModule();
      // Nothing disabled, should work normally
      assert.equal(isHookEnabled('session-init'), true);
      assert.equal(isHookEnabled('observe'), true);
    });

    it('disabled hooks override even strict profile', () => {
      process.env.TEMPLATE_HOOK_PROFILE = 'strict';
      process.env.TEMPLATE_DISABLED_HOOKS = 'quality-gate,file-size-guard';
      const { isHookEnabled } = loadModule();
      assert.equal(isHookEnabled('quality-gate'), false);
      assert.equal(isHookEnabled('file-size-guard'), false);
      // Other strict hooks still enabled
      assert.equal(isHookEnabled('cost-tracker'), true);
      assert.equal(isHookEnabled('typescript-check'), true);
    });
  });

  // ─── options.profiles override ───

  describe('with profiles option override', () => {
    it('uses custom profiles when passed as option', () => {
      const { isHookEnabled } = loadModule();
      const customProfiles = {
        minimal: ['hook-a'],
        standard: ['hook-a', 'hook-b'],
        strict: ['hook-a', 'hook-b', 'hook-c'],
      };
      // Default profile is standard
      assert.equal(isHookEnabled('hook-b', { profiles: customProfiles }), true);
      assert.equal(isHookEnabled('hook-c', { profiles: customProfiles }), false);
    });
  });
});

// ─── getProfile() ──────────────────────────────────────────────

describe('getProfile()', () => {
  it('is exported as a function', () => {
    const { getProfile } = loadModule();
    assert.equal(typeof getProfile, 'function');
  });

  it('returns "standard" when no env var is set', () => {
    const { getProfile } = loadModule();
    assert.equal(getProfile(), 'standard');
  });

  it('returns the env var value when set', () => {
    process.env.TEMPLATE_HOOK_PROFILE = 'minimal';
    const { getProfile } = loadModule();
    assert.equal(getProfile(), 'minimal');
  });

  it('returns "standard" for unknown profile names', () => {
    process.env.TEMPLATE_HOOK_PROFILE = 'turbo';
    const { getProfile } = loadModule();
    assert.equal(getProfile(), 'standard');
  });
});

// ─── getEnabledHooks() ────────────────────────────────────────

describe('getEnabledHooks()', () => {
  it('is exported as a function', () => {
    const { getEnabledHooks } = loadModule();
    assert.equal(typeof getEnabledHooks, 'function');
  });

  it('returns the list of enabled hooks for current profile', () => {
    process.env.TEMPLATE_HOOK_PROFILE = 'minimal';
    const { getEnabledHooks } = loadModule();
    const hooks = getEnabledHooks();
    assert.ok(Array.isArray(hooks));
    assert.ok(hooks.includes('session-init'));
    assert.ok(!hooks.includes('observe'));
  });

  it('excludes disabled hooks from the list', () => {
    process.env.TEMPLATE_DISABLED_HOOKS = 'session-init';
    const { getEnabledHooks } = loadModule();
    const hooks = getEnabledHooks();
    assert.ok(!hooks.includes('session-init'));
  });
});
