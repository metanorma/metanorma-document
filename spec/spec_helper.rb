# frozen_string_literal: true

require "metanorma/document"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :should
  end
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

def each_fixture_path_does(description, &block)
  context description do
    Dir[fixture_path("*")].each do |fixture_path|
      fixture = File.basename(fixture_path, ".xml")

      it "for fixture #{fixture}" do
        self.instance_exec(fixture_path, &block)
      end
    end
  end
end
