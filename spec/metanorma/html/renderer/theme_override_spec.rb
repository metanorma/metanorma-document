# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"
require "tmpdir"

RSpec.describe "Theme override via Generator.generate" do
  let(:xml_path) do
    File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                     __dir__)
  end
  let(:doc) { Metanorma::IsoDocument::Root.from_xml(File.read(xml_path)) }

  it "uses an external theme directory (theme.yaml + custom.css)" do
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "theme.yaml"), <<~YAML)
        primary: "#123456"
        publisher_name: "ACME"
      YAML
      File.write(File.join(dir, "custom.css"), "/* acme-custom-marker */\n")

      html = Metanorma::Html::Generator.generate(doc, theme: dir)

      expect(html).to include("--mn-primary: #123456")
      expect(html).to include("acme-custom-marker")
    end
  end

  it "uses a bare theme.yaml file" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "acme.yaml")
      File.write(path, "primary: \"#654321\"\n")

      html = Metanorma::Html::Generator.generate(doc, theme: path)

      expect(html).to include("--mn-primary: #654321")
    end
  end

  it "uses a Theme instance" do
    theme = Metanorma::Html::Theme.new(primary: "#aabbcc")

    html = Metanorma::Html::Generator.generate(doc, theme: theme)

    expect(html).to include("--mn-primary: #aabbcc")
  end
end
