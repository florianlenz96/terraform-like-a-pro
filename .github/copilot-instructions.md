# Copilot Instructions

## Commit Policy

**Never commit or push without explicit user approval.**

Before any `git commit` or `git push`, always ask the user first using `ask_user`.
This applies to all tasks regardless of size — Small, Medium, or Large.

Acceptable phrases from the user that constitute approval:
- "commit it", "go ahead and commit", "commit this", "yes commit"

Do NOT treat task completion or "done" as implicit approval to commit.

## Anvil Agent — Commit Override

The Anvil agent's default Step 8 behavior (auto-commit after presenting) is **disabled** for this repository.

For **Small tasks**: do NOT auto-commit. Use `ask_user` with choices "Commit this change" / "I'll commit later".
For **Medium and Large tasks**: do NOT auto-commit after presenting the Evidence Bundle. Use `ask_user` with choices "Commit this change" / "I'll commit later".

This overrides the Anvil loop's Step 8 in all cases.
