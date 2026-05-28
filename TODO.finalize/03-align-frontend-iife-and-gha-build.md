# 03 — Align frontend IIFE build and GHA gem release with docbook pattern

## Problem
The frontend build and gem release pipeline does not follow the established docbook pattern:
1. `Rakefile` lacks `build_frontend` task and `release` hook
2. `gemspec` doesn't include `frontend/dist/*` and `frontend/src/**/*`
3. GHA `rake.yml` lacks `after-setup-ruby: cd frontend && npm install && npm run build`
4. The Vite config is close but should be verified to produce identical output structure

## Target pattern (from docbook)

### Rakefile addition
```ruby
desc "Build frontend SPA assets"
task :build_frontend do
  frontend_dir = File.join(__dir__, "frontend")
  puts "Building frontend..."
  system("cd #{frontend_dir} && npm install && npm run build") || raise("Frontend build failed")
end
Rake::Task["release"].enhance(["build_frontend"]) if Rake::Task.task_defined?("release")
```

### gemspec addition
```ruby
# Include frontend dist assets (built locally, not committed to git)
Dir.glob("frontend/dist/*").each { |f| spec.files << f }
Dir.glob("frontend/src/**/*").each { |f| spec.files << f }
```

### GHA rake.yml
```yaml
jobs:
  rake:
    uses: metanorma/ci/.github/workflows/generic-rake.yml@main
    with:
      after-setup-ruby: cd frontend && npm install && npm run build
      setup-tools: libreoffice
      submodules: false
    secrets:
      pat_token: ${{ secrets.METANORMA_CI_PAT_TOKEN }}
```

### .gitignore additions
```
# Frontend build artifacts (bundled into gem, not committed)
frontend/node_modules/
frontend/dist/
```
(already partially done)

### Frontend vite.config.ts
Verify the IIFE config produces `app.iife.js` and `app.css` in `frontend/dist/`, matching docbook's:
```ts
build: {
  lib: {
    entry: resolve(__dirname, 'src/app.ts'),
    name: 'MetanormaSpa',
    fileName: 'app',
    formats: ['iife']
  },
  rollupOptions: {
    output: {
      inlineDynamicImports: true,
      assetFileNames: 'app.[ext]'
    }
  }
}
```

## Steps
1. Add `build_frontend` Rake task and release hook
2. Update gemspec to include `frontend/dist/*` and `frontend/src/**/*`
3. Update `.github/workflows/rake.yml` with `after-setup-ruby`
4. Verify `.gitignore` has `frontend/node_modules/` and `frontend/dist/`
5. Verify `vite.config.ts` output matches docbook's pattern
6. Run `cd frontend && npm install && npm run build` locally to verify output
7. Verify the gem builds correctly with `gem build metanorma-document.gemspec`

## Code quality requirements
Ensure code cleanliness and OOP and MECE and fully model-driven, semantically-driven and open/closed principle, DRY, performance. ultrathink. Always think about what can we improve here in architecture and code? Make sure we have good specs throughout. Never use private send methods (breaks encapsulation), instance_variable_set/get, and never use respond_to? (poor typing).
