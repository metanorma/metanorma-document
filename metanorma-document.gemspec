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
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/metanorma/metanorma-document"
  spec.metadata["changelog_uri"] = "https://github.com/metanorma/metanorma-document/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|features)/})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "lutaml-model", "~> 0.8.0"
end
