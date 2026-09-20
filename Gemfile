# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in metanorma-standoc-document.gemspec
gemspec

# The 0.2.x maintenance line serves the metanorma-cli 0.2.x bundle,
# whose relaton keeps rubyzip ~> 2.3 and therefore resolves
# lutaml-model below 0.8.31 (0.8.31+ needs rubyzip ~> 3.4). Released
# gems only: the upstream main branches move past this line.
if ENV["CI"]
  gem "canon"
  gem "lutaml-model", "~> 0.8.0", "< 0.8.31"
  gem "mml", "~> 2.4"
  gem "moxml", "~> 0.5.0"
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

gem "concurrent-ruby", "~> 1.3"
