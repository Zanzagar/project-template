# Onboarding

## 1. Clone & Setup
```bash
git clone <repo-url>
cd __PROJECT_NAME__
python3 -m venv .venv && source .venv/bin/activate
pip install -e .[dev]
pre-commit install
```

## 2. Verify Locally
```bash
pre-commit run --all-files
pytest -q
```

## 3. Learn the Workflow
- Read `docs/WORKFLOW.md` and `.taskmaster/docs/prd_*.txt`.
- Review `AGENTS.md` for responsibilities.

## 4. Make a Change
- Branch from `main`: `feature/<scope>`.
- Update guardrails + docs when behavior changes.

## 5. Open a PR
- Ensure CI green, link to PRD, record review findings.
