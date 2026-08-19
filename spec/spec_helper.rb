# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start { add_filter "/spec/" }
end

require_relative "../lib/metanorma/document"
# The Html/Mirror subsystems render flavor documents; their specs
# exercise Standoc/ISO/ITU models. The gems are dev-time Gemfile pins.
require "metanorma/standoc"
require "metanorma/iso/document"
require "metanorma/itu/document"
Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

# Spec-side flavor registration (mirrors what flavour gems ship via
# Metanorma::Html.register_flavor); exercises the extension seam.
SpecFlavors.register!

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require "nokogiri"
Lutaml::Model::Config.configure do |config|
  config.xml_adapter_type = :nokogiri
end

require "canon"
Canon::Config.configure do |config|
  config.xml.match.profile = :spec_friendly
  config.xml.diff.use_color = true
end

def fixture_path(name)
  "#{__dir__}/fixtures/#{name}.xml"
end

def parse_path(path)
  parse(File.open(path))
end

def parse(input)
  Metanorma::Document(input)
end

def fixture(name)
  parse_path(fixture_path(name))
end
