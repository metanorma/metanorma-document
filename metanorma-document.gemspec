# frozen_string_literal: true

require_relative "lib/metanorma/document/version"

Gem::Specification.new do |spec|
  spec.name          = "metanorma-document"
  spec.version       = Metanorma::Document::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Library for Metanorma document XML"
  spec.description   = "A Ruby library for representing and processing Metanorma document XML, providing a comprehensive model for standards documents with support for various metadata, content blocks, and structured markup."
  spec.homepage      = "https://github.com/metanorma/metanorma-document"
  spec.license       = "BSD-2-Clause"
  spec.required_ruby_version = ">= 3.3"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/metanorma/metanorma-document"
  spec.metadata["changelog_uri"] = "https://github.com/metanorma/metanorma-document/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__,
                                             err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/
                          .rubocop.yml .rubocop_todo.yml TODO docs/
                          lib/data/])
    end
  end
  # Include frontend dist assets (built locally, not committed to git)
  Dir.glob("frontend/dist/*").each { |f| spec.files << f }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "lutaml-model", "~> 0.8.0"
  spec.add_dependency "mml", "~> 2.4"
  # pubid has no stable 2.x release yet (latest: 2.0.0.pre.alpha.x);
  # relax this pin once pubid 2.0.0 ships.
  spec.add_dependency "pubid", "~> 2.0.0.pre.alpha"
  # Tracking the relaton 2.0 prerelease line for the relaton-bib
  # migration (P3.18); pin to stable once relaton-bib 2.2.0 ships.
  spec.add_dependency "relaton-bib", ">= 2.2.0.pre.alpha.1", "< 2.3.0"
end
