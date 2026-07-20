# frozen_string_literal: true

require "spec_helper"
require "metanorma/document"
require "metanorma/mirror"
require "tmpdir"

RSpec.describe Metanorma::Document::CLI do
  describe ".run" do
    it "shows usage with no arguments" do
      stdout = capture_stdout { described_class.run([]) }
      expect(stdout).to include("Usage:")
    end

    it "shows usage with --help" do
      stdout = capture_stdout { described_class.run(["--help"]) }
      expect(stdout).to include("Usage:")
    end

    it "raises error for unknown command" do
      expect do
        described_class.run(["unknown"])
      end.to raise_error(
        Metanorma::Document::CLI::Error, /Unknown command/
      )
    end
  end

  describe ".to_mirror" do
    it "raises error when no XML path provided" do
      expect do
        described_class.to_mirror([])
      end.to raise_error(
        Metanorma::Document::CLI::Error, /XML path required/
      )
    end

    it "raises error when file not found" do
      expect do
        described_class.to_mirror(["/nonexistent/file.xml"])
      end.to raise_error(
        Metanorma::Document::CLI::Error, /File not found/
      )
    end

    it "raises error for unknown id-strategy" do
      expect do
        described_class.to_mirror(["--id-strategy", "bogus",
                                   "file.xml"])
      end.to raise_error(Metanorma::Document::CLI::Error,
                         /Unknown ID strategy/)
    end
  end

  describe ".to_html" do
    let(:xml_path) do
      File.expand_path("../../fixtures/iso/is/document-en.presentation.xml",
                       __dir__)
    end

    it "raises error when no XML path provided" do
      expect { described_class.to_html([]) }.to raise_error(
        Metanorma::Document::CLI::Error, /XML path required/
      )
    end

    it "raises error when file not found" do
      expect { described_class.to_html(["/nonexistent/file.xml"]) }
        .to raise_error(
          Metanorma::Document::CLI::Error, /File not found/
        )
    end

    it "renders standalone HTML to stdout" do
      stdout = capture_stdout do
        described_class.to_html(["-f", "iso", xml_path])
      end
      expect(stdout).to include("<!DOCTYPE html>")
      expect(stdout).to include("</html>")
    end

    it "writes HTML to an output file" do
      Dir.mktmpdir do |dir|
        out = File.join(dir, "out.html")
        described_class.to_html(["-f", "iso", "-o", out, xml_path])
        expect(File.exist?(out)).to be(true)
        expect(File.read(out)).to include("<!DOCTYPE html>")
      end
    end
  end

  def capture_stdout
    old = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old
  end
end
