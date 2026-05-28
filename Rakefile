# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

# Load custom tasks
Dir.glob("lib/tasks/*.rake").each { |task| load task }

# Build the frontend SPA (frontend/dist/)
desc "Build frontend SPA assets"
task :build_frontend do
  frontend_dir = File.join(__dir__, "frontend")
  puts "Building frontend..."
  system("cd #{frontend_dir} && npm install && npm run build") || raise("Frontend build failed")
end

# Hook into bundler's release task to ensure frontend is built
Rake::Task["release"].enhance(["build_frontend"]) if Rake::Task.task_defined?("release")

task default: %i[spec rubocop]
