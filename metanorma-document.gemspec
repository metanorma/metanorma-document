# frozen_string_literal: true

require_relative "lib/metanorma/document/version"

Gem::Specification.new do |spec|
  spec.name          = "metanorma-document"
  spec.version       = Metanorma::Document::VERSION
  spec.authors       = ["TxODO: Write your name"]
  spec.email         = ["TxODO: Write your email address"]

  spec.summary       = "TxODO: Write a short summary, because RubyGems requires one."
  spec.description   = "TxODO: Write a longer description or delete this line."
  spec.homepage      = "http://x.xx/TxODO:_Put_your_gem's_website_or_public_repo_URL_here."
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.5.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "http://x.xx/TxODO:_Put_your_gem's_public_repo_URL_here."
  spec.metadata["changelog_uri"] = "http://x.xx/TxODO:_Put_your_gem's_CHANGELOG.md_URL_here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "nokogiri"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
