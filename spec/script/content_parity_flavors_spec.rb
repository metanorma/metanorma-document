# frozen_string_literal: true

require "spec_helper"
load File.expand_path("../../script/content_parity.rb", __dir__)

# No-content-loss check (metanorma-document#114): render the sample document
# for each flavor gem present in the bundle with legacy isodoc and with the
# new HTML generator, and require that every legacy text block and heading
# is present in the new output. Flavors whose gem is not installed are
# skipped (the script reports them as source-failed).
#
# KNOWN_LOSSES lists the text blocks that are currently absent from the new
# output. The spec fails on any additional loss, so the list can only shrink.
RSpec.describe "content parity, new HTML vs legacy isodoc" do
  KNOWN_LOSSES = {
    "cc" => ["3.1."],
    "generic" => ["3.1."],
    "itu" => ["Recommendation ITU-T 1000", "3.1. sample term:"],
    "ogc" => ["other term ALTERNATIVE"],
  }.freeze

  # Flavor gems share global state (isodoc classes, i18n), so as in the
  # script's own --all mode each flavor is rendered in a fresh process.
  def run_in_subprocess(flavor, sample)
    script = File.expand_path("../../script/content_parity.rb", __dir__)
    code = <<~RUBY
      load #{script.inspect}
      puts JSON.generate(ContentParity.run_case(#{flavor.inspect}, "sample", adoc: #{sample.inspect}))
    RUBY
    out, = Open3.capture2("bundle", "exec", "ruby", "-e", code)
    JSON.parse(out.lines.last)
  end

  it "loses no text content for the iso fixture document" do
    xml = File.expand_path("../fixtures/iso/is/document-en.presentation.xml",
                           __dir__)
    script = File.expand_path("../../script/content_parity.rb", __dir__)
    code = <<~RUBY
      load #{script.inspect}
      puts JSON.generate(ContentParity.run_case("iso", "fixture", xml: #{xml.inspect}))
    RUBY
    out, = Open3.capture2("bundle", "exec", "ruby", "-e", code)
    result = JSON.parse(out.lines.last)
    expect(result["status"]).to eq("compared"), result["error"].to_s
    expect(result["missing_blocks"]).to be_empty
  end

  %w[iso iec cc generic itu ogc jis plateau].each do |flavor|
    it "loses no text content for the #{flavor} sample document" do
      sample = File.join(ContentParity::FIXTURE_DIR, "sample.adoc")
      result = run_in_subprocess(flavor, sample)
      if result["status"] == "source-failed" && result["error"].include?("LoadError")
        skip "metanorma-#{flavor} is not in the bundle"
      end

      expect(result["status"]).to eq("compared"), result["error"].to_s
      expect(result["missing_headings"]).to be_empty
      lost = result["missing_blocks"].map { |b| b["text"] }
      expect(lost - KNOWN_LOSSES.fetch(flavor, [])).to be_empty
    end
  end
end
