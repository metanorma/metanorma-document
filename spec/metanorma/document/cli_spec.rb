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

    it "does not render the section xref label as body text" do
      # The section's fmt-xref-label ("Clause 3", "1.1") belongs inside
      # cross-references; the heading already carries the number, so a
      # stray label right after a heading is a rendering defect.
      Dir.mktmpdir do |dir|
        out = File.join(dir, "out.html")
        described_class.to_html(["-f", "iso", "-o", out, xml_path])
        html = File.read(out)
        expect(html).not_to match(%r{</h\d><span class="element-label">})
        expect(html).not_to match(%r{</h\d>\d})
      end
    end
  end

  describe ".canonical_flavor" do
    after do
      # The registry is process-global: the theme-matrix spec classifies
      # every loaded entry, so taste fixtures must not survive this block.
      require "metanorma-core"
      flavors = Metanorma::Core::Flavors.table
        .instance_variable_get(:@flavors)
      flavors.reject! { |f| f.name.to_s.start_with?("taste-spec-canonical") }
    end

    it "maps a taste to its base flavor's model owner" do
      require "metanorma-core"
      base = "taste-spec-canonical-base"
      taste = "taste-spec-canonical"
      Metanorma::Core::Flavors.register(
        Metanorma::Core::Flavor.new(name: base, gem: "metanorma-standoc"),
      )
      Metanorma::Core::Flavors.register(
        Metanorma::Core::Flavor.new(name: taste, base_flavor: base.to_sym,
                                    gem: "metanorma-taste"),
      )
      expect(described_class.canonical_flavor(taste)).to eq(base)
    end

    it "passes unknown flavors through untouched" do
      expect(described_class.canonical_flavor("nosuch-flavor"))
        .to eq("nosuch-flavor")
    end

    it "returns the flavor itself for a registered flavor" do
      expect(described_class.canonical_flavor("iso")).to eq("iso")
    end

    it "tolerates nil" do
      expect(described_class.canonical_flavor(nil)).to be_nil
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
