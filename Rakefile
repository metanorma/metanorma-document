# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

# Fast gate: the full suite minus the multi-MB-fixture specs; the
# per-flavor roundtrips moved to the flavor gems (Phase 5).
RSpec::Core::RakeTask.new(:spec_fast)

require "rubocop/rake_task"

RuboCop::RakeTask.new

# Load custom tasks
Dir.glob(File.join(__dir__, "tasks", "*.rake")).each { |task| load task }

# Build the frontend SPA (frontend/dist/)
desc "Build frontend SPA assets"
task :build_frontend do
  frontend_dir = File.join(__dir__, "frontend")
  puts "Building frontend..."
  # npx npm@11 ci: package-lock.json is npm-11-shaped (npm 10 and npm 11
  # produce mutually incompatible locks here), and the release runner's
  # default Node ships npm 10. npx fetches npm 11 on demand; ci never
  # rewrites the lock (keeps release:guard_clean green).
  system("cd #{frontend_dir} && npx -y npm@11 ci && npm run build") || raise("Frontend build failed")
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
