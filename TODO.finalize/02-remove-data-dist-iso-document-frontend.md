# 02 — Remove misplaced `data/dist/iso_document/frontend/` artifacts

## Problem
`data/dist/iso_document/frontend/` contains Vite-bundled frontend assets (hashed font files, `index.html`) that belong in `frontend/dist/`, not nested inside `data/dist/iso_document/`. This is leftover from a previous build configuration.

The correct structure (matching docbook project) is:
- `frontend/dist/app.iife.js` — bundled JS (IIFE)
- `frontend/dist/app.css` — bundled CSS
- These get included in the gem via gemspec `Dir.glob("frontend/dist/*")`

## Steps
1. Delete `data/dist/iso_document/frontend/` entirely
2. Verify gemspec includes `frontend/dist/*` (matching docbook pattern)
3. Verify `data/dist/` is in `.gitignore` (already is)
4. Ensure nothing references the old path

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
