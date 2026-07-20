# frozen_string_literal: true

# Benchmark: parse + HTML-render a presentation XML fixture.
#
# Usage:
#   bundle install          # benchmark-ips is a dev dependency
#   bundle exec ruby script/benchmark_render.rb [fixture.xml]

require "benchmark/ips"
require_relative "../lib/metanorma/document"
require_relative "../lib/metanorma/html"

fixture = ARGV[0] ||
  File.expand_path("../spec/fixtures/iso/is/document-en.presentation.xml",
                   __dir__)
xml = File.read(fixture)
puts "Fixture: #{fixture} (#{(xml.size / 1024.0).round(1)} KB)"

doc = Metanorma::IsoDocument::Root.from_xml(xml)
html = Metanorma::Html::Generator.generate(doc)
puts "Sanity: rendered #{html.size} bytes of HTML"

Benchmark.ips do |x|
  x.config(time: 5, warmup: 1)

  x.report("parse") do
    Metanorma::IsoDocument::Root.from_xml(xml)
  end

  x.report("render") do
    Metanorma::Html::Generator.generate(doc)
  end

  x.compare!
end
