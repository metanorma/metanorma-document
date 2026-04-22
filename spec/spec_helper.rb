# frozen_string_literal: true

require_relative "../lib/metanorma/document"

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :should
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

def each_fixture_path_does(description, &)
  context description do
    Dir[fixture_path("*")].each do |fixture_path|
      fixture = File.basename(fixture_path, ".xml")

      it "for fixture #{fixture}" do
        instance_exec(fixture_path, &)
      end
    end
  end
end
