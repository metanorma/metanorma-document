# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in metanorma-document.gemspec
gemspec

# TEMPORARY branch pins so the Html/Mirror specs (which render flavor
# documents) resolve against the new canonical homes during the
# model-ownership migration. standoc#1232, itu#832, core#18 and isodoc#825
# merged and now track main. Still pinned until their PRs reach main:
#   - iso: #1618 merged into the feat/sts-transformer-architecture stack,
#     not main; flip once that stack lands on main
# gem "glossarist", "~> 2.13"
gem "isodoc", github: "metanorma/isodoc", branch: "main"
gem "metanorma-core", github: "metanorma/metanorma-core", branch: "main"
gem "metanorma-iec", github: "metanorma/metanorma-iec", branch: "main"
gem "metanorma-iso", github: "metanorma/metanorma-iso", branch: "feat/model-validation-migration"
gem "metanorma-itu", github: "metanorma/metanorma-itu", branch: "main"
# mko >= 1.1.0 from rubygems carries Mko::Language
# TEMPORARY pin: the svgmap/imagemap handlers (metanorma-mirror#1) —
# flip to main on merge, to the version on release.
gem "metanorma-mirror", github: "metanorma/metanorma-mirror", branch: "feat/svgmap-imagemap-handlers"
gem "metanorma-mko"
gem "metanorma-ogc", github: "metanorma/metanorma-ogc", branch: "main"
gem "metanorma-standoc", github: "metanorma/metanorma-standoc", branch: "main"
gem "plurimath", "~> 0.11"
gem "pubid", ">= 2.0.0.pre.alpha.9"

# Dependency sources. Default (no env vars): released gems, exactly the
# contract downstream users get — CI and local dev must test that.
# METANORMA_CI_EDGE=1   -> track upstream main branches (bleeding-edge CI).
# METANORMA_DEV_LOCAL=1 -> sibling checkouts on the author's machine.
if ENV["METANORMA_CI_EDGE"]
  gem "canon", github: "lutaml/canon", branch: "main"
  gem "mml", github: "plurimath/mml", branch: "main"
elsif ENV["METANORMA_DEV_LOCAL"]
  gem "canon", path: "../../lutaml/canon"
  gem "mml", path: "../../plurimath/mml"
end

gem "nokogiri"
# 0.8.20 yanked; keep the lock below it (github/path pins above override)
# 0.8.20 was yanked; 0.8.22+ pairs with moxml 0.5 whose preferred
# adapter is leptris (fastest on every measured op per lutaml/moxml#96)
gem "leptris", "~> 1.9"
# TEMPORARY pin: the json 3.0 to_json fix (lutaml-model#769) — flip to
# the released version when it ships.
gem "lutaml-model", github: "lutaml/lutaml-model", branch: "fix/767-json-register-kwarg"
gem "moxml", "~> 0.5.30"
gem "omml", github: "plurimath/omml", branch: "moxml-0.5-range" # TEMPORARY: moxml-0.5 range (plurimath/omml#11); flip to released version
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
