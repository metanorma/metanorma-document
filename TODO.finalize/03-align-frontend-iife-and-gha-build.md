# 03 — Align frontend IIFE build and GHA gem release with docbook pattern — DONE

Aligned with docbook project:
- `Rakefile` has `build_frontend` task + release hook
- `gemspec` includes `frontend/dist/*`
- `.github/workflows/rake.yml` has `after-setup-ruby: cd frontend && npm install && npm run build`
- `frontend/vite.config.ts` produces `app.iife.js` + `app.css`
- `.gitignore` has `frontend/node_modules/` and `frontend/dist/`

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
