# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in metanorma-document.gemspec
gemspec

# Dependency sources. Default (no env vars): released gems, exactly the
# contract downstream users get — CI and local dev must test that.
# METANORMA_CI_EDGE=1   -> track upstream main branches (bleeding-edge CI).
# METANORMA_DEV_LOCAL=1 -> sibling checkouts on the author's machine.
if ENV["METANORMA_CI_EDGE"]
  gem "canon", github: "lutaml/canon", branch: "main"
  gem "lutaml-model", github: "lutaml/lutaml-model", branch: "main"
  gem "mml", github: "plurimath/mml", branch: "main"
  gem "moxml", github: "lutaml/moxml", branch: "main"
elsif ENV["METANORMA_DEV_LOCAL"]
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

gem "benchmark-ips"
gem "concurrent-ruby", "~> 1.3"
gem "simplecov", require: false
