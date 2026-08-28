# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in metanorma-document.gemspec
gemspec

# TEMPORARY: cross-PR branch pins so the Html/Mirror specs (which render
# flavor documents) resolve against the new canonical homes during the
# model-ownership migration. Revert each once its PR merges:
#   - https://github.com/metanorma/metanorma-standoc/pull/1232
#   - https://github.com/metanorma/metanorma-iso/pull/1618
#   - https://github.com/metanorma/metanorma-itu/pull/832
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "feat/move-standard-document"
gem "metanorma-core", github: "metanorma/metanorma-core", branch: "feat/flavor-table"
gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "feat/model-validation-migration"
gem "metanorma-itu", github: "metanorma/metanorma-itu", branch: "feat/move-itu-document"
gem "metanorma-ogc", github: "metanorma/metanorma-ogc", branch: "feat/move-ogc-document"
gem "metanorma-iec", github: "metanorma/metanorma-iec", branch: "feat/move-iec-document"
gem "isodoc", github: "metanorma/isodoc", branch: "rt-pubid-2-migration"
gem "pubid", ">= 2.0.0.pre.alpha.9"
gem "glossarist", "~> 2.13"

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
