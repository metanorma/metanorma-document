# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in metanorma-standoc-document.gemspec
gemspec

if ENV["CI"]
  gem "canon", github: "lutaml/canon", branch: "main"
  gem "lutaml-model", github: "lutaml/lutaml-model", branch: "main"
  gem "mml", github: "plurimath/mml", branch: "main"
  gem "moxml", github: "lutaml/moxml", branch: "main"
else
  gem "canon", path: "../../lutaml/canon"
  gem "lutaml-model", path: "../../lutaml/lutaml-model"
  gem "mml", path: "../../plurimath/mml"
end

gem "nokogiri"
gem "rake", "~> 13.0"
gem "rdoc"
gem "rspec", "~> 3.0"
gem "rubocop"
gem "rubocop-performance"
gem "rubocop-rake"
gem "rubocop-rspec"
