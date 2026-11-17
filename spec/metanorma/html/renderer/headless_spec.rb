# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"
require "metanorma/document/cli"
require "tmpdir"

RSpec.describe "Headless HTML" do
  let(:document) { Metanorma::Standoc::Document::Root.new(type: "presentation") }

  it "renders the body layout inside a div without a document head" do
    output = Metanorma::Html::Generator.generate(document, headless: true)
    expect(output.lstrip).to start_with('<div lang="')
    expect(output).not_to match(/<!DOCTYPE|<html\b|<head\b|<body\b/)
    expect(output).to include('id="doc-content"', 'class="skip-nav"')
    expect(output.rstrip).to end_with("</div>")
  end

  it "keeps the body layout and scripts identical to standalone output" do
    full = Metanorma::Html::Generator.generate(document)
    headless = Metanorma::Html::Generator.generate(document, headless: true)
    full_body = full.split(/<body[^>]*>/, 2).last.split("</body>").first.strip
    fragment_body = headless.sub(/\A\s*<div[^>]*>/, "").sub(%r{</div>\s*\z}, "").strip
    expect(fragment_body).to eq(full_body)
    expect(full).to include("<!DOCTYPE html>", "<head>", "<body")
  end

  it "accepts the headless CLI option" do
    path = File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml", __dir__)
    options = Metanorma::Document::CLI.parse_to_html_options(["--headless", path])
    expect(options.headless).to be(true)
    expect(Metanorma::Document::CLI.parse_to_html_options([path]).headless).to be(false)
  end

  it "writes headless HTML for a real ISO presentation document through the CLI" do
    input = File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml", __dir__)
    Dir.mktmpdir("b1-headless") do |dir|
      path = File.join(dir, "output.html")
      Metanorma::Document::CLI.to_html(["--headless", "--flavor", "iso", "--output", path, input])
      output = File.read(path)
      expect(output.lstrip).to start_with('<div lang="')
      expect(output).not_to include("<head>", "<body", "<!DOCTYPE")
      expect(output).to include('id="doc-content"', 'class="title-section"')
    end
  end

  it "keeps body-only generation available for hosts supplying their own layout" do
    renderer = Metanorma::Html::StandardRenderer.new
    body = renderer.generate_body(document)
    expect(body).not_to include('class="skip-nav"', "<head>")
  end
end
