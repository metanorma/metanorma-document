# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

# Fast gate: the full suite minus the roundtrip specs over multi-MB
# fixtures (spec/metanorma/iso_document/roundtrip/**), which dominate
# runtime. Those run in .github/workflows/roundtrip.yml; run the full
# suite locally with `rake spec`.
RSpec::Core::RakeTask.new(:spec_fast) do |t|
  t.exclude_pattern = "spec/metanorma/iso_document/roundtrip/**"
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

# Load custom tasks
Dir.glob(File.join(__dir__, "tasks", "*.rake")).each { |task| load task }

# Build the frontend SPA (frontend/dist/)
desc "Build frontend SPA assets"
task :build_frontend do
  frontend_dir = File.join(__dir__, "frontend")
  puts "Building frontend..."
  # npm ci (not npm install): it never rewrites package-lock.json, which
  # would dirty the tree and trip bundler's release:guard_clean.
  system("cd #{frontend_dir} && npm ci && npm run build") || raise("Frontend build failed")
end

# Abort packaging if the SPA bundle is missing — the gem must never
# ship without frontend assets (0.3.0 did, silently).
desc "Verify frontend assets exist for packaging"
task :ensure_frontend_dist do
  bundle = File.join(__dir__, "frontend", "dist", "app.iife.js")
  unless File.exist?(bundle)
    abort("ERROR: #{bundle} is missing; the gem would ship without " \
          "the SPA. Run `rake build_frontend` first.")
  end
end

# bundler's `release` depends on `build`, so enhancing `build` covers both.
if Rake::Task.task_defined?("build")
  Rake::Task["build"].enhance(["build_frontend", "ensure_frontend_dist"])
end

task default: %i[spec_fast rubocop]
