# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "tmpdir"

RSpec.describe Metanorma::Mirror::Output::Formats::InlineFormat do
  let(:xml_path) do
    File.expand_path("../../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end

  let(:pipeline) do
    Metanorma::Mirror::Output::Pipeline.new(xml_path: xml_path, flavor: "iso")
  end

  let(:guide) { pipeline.process }

  before { described_class.missing_bundle_warned = false }

  describe "#write without the IIFE bundle" do
    it "warns on stderr and still writes static HTML", :aggregate_failures do
      Dir.mktmpdir do |dist|
        Dir.mktmpdir do |dir|
          output = File.join(dir, "out.html")
          formatter = described_class.new(dist_dir: dist)

          expect { formatter.write(output, guide) }
            .to output(/app\.iife\.js/).to_stderr
          expect(File.exist?(output)).to be true
          expect(File.read(output)).not_to include('id="metanorma-app"')
        end
      end
    end
  end
end
