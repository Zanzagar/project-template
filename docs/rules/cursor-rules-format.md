<!-- template-version: 1.0.0 -->
<!-- template-file: docs/rules/cursor-rules-format.md -->
# Cursor Rules Format Guide

Guidelines for creating and maintaining AI assistant rules to ensure consistency and effectiveness.

## Required Rule Structure

```markdown
# Rule Title

Brief description of what the rule covers.

## Section 1
- **Main points in bold**
  - Sub-points with details
  - Examples and explanations

## Section 2
...
```

## File References

Use relative links to reference other files:
- `[filename](./path/to/file)` for rule references
- `[schema.py](../../src/schema.py)` for code references

## Code Examples

Use language-specific code blocks with clear labels:

```python
# DO: Show good examples
def good_example():
    return True

# DON'T: Show anti-patterns
def bad_example():
    return false  # syntax error
```

## Rule Content Guidelines

1. **Start with high-level overview** - What does this rule cover?
2. **Include specific, actionable requirements** - What must be done?
3. **Show examples of correct implementation** - How should it look?
4. **Reference existing code when possible** - Where is it used?
5. **Keep rules DRY** - Reference other rules instead of duplicating

## Best Practices

- Use bullet points for clarity
- Keep descriptions concise
- Include both DO and DON'T examples
- Reference actual code over theoretical examples
- Use consistent formatting across all rules
- Update rules when patterns change

## Rule Maintenance

- Review rules quarterly for relevance
- Update examples from actual codebase
- Remove outdated patterns
- Cross-reference related rules
- Document rule changes in commits
