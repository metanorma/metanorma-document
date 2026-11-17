# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"
require "tmpdir"

RSpec.describe "Configurable HTML front matter" do
  let(:renderer) { Metanorma::Html::StandardRenderer.new }
  let(:document) do
    Metanorma::Standoc::Document::Root.from_xml(<<~XML)
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation">
        <bibdata><title language="en">A &amp; B</title><docidentifier>TEST 1</docidentifier></bibdata>
        <boilerplate><copyright-statement><p>Copyright holder</p></copyright-statement></boilerplate>
        <sections><clause id="c"><title>Main</title><p>Content</p><note coverpage="true"><p>Cover note</p></note><admonition type="warning" coverpage="true"><p>Cover warning</p></admonition></clause></sections>
      </metanorma>
    XML
  end

  def with_theme(config, templates)
    Dir.mktmpdir("b1-theme") do |dir|
      File.write(File.join(dir, "theme.yaml"), config)
      Dir.mkdir(File.join(dir, "templates"))
      templates.each { |name, content| File.write(File.join(dir, "templates", name), content) }
      yield dir
    end
  end

  it "orders independent cover, titlepage and intro slots before the document" do
    config = <<~YAML
      publisher_name: Example
      cover_template: cover.liquid
      titlepage_template: title.liquid
      intro_template: intro.liquid
      boilerplate_placement: intro
    YAML
    templates = {
      "cover.liquid" => '<div id="bespoke-cover">{{ title | escape }}{{ cover_notes_html }}</div>',
      "title.liquid" => '<div id="bespoke-title">{{ doc_id | escape }}</div>',
      "intro.liquid" => '<div id="bespoke-intro">{{ boilerplate_html }}</div>',
    }
    with_theme(config, templates) do |theme|
      html = renderer.generate_full_document(document, theme: theme)
      expect(html).to include('id="bespoke-cover">A &amp; B', 'id="bespoke-title">TEST 1')
      expect(html.index('id="bespoke-cover"')).to be < html.index('id="bespoke-title"')
      expect(html.index('id="bespoke-title"')).to be < html.index('id="bespoke-intro"')
      expect(html.index('id="bespoke-intro"')).to be < html.index('id="c"')
      expect(html.scan("Cover note").size).to eq(1)
      expect(html.scan("Cover warning").size).to eq(1)
      expect(html.scan("Copyright holder").size).to eq(1)
      expect(html).not_to include('coverpage="')
    end
  end

  it "uses shared cover rendering when only the intro is overridden" do
    with_theme("intro_template: intro.liquid\n", "intro.liquid" => '<div id="intro">{{ publisher_name | escape }}</div>') do |theme|
      html = renderer.generate_full_document(document, theme: theme)
      expect(html).to include('class="title-section"', 'id="intro"', "Copyright holder", "Cover note")
      expect(html.scan("Cover note").size).to eq(1)
      expect(html.scan("Cover warning").size).to eq(1)
    end
  end

  it "provides statement destinations as lazy typed-model renders" do
    with_theme("intro_template: intro.liquid\nboilerplate_placement: template\n", "intro.liquid" => '{{ front_matter.copyright_html }}') do |theme|
      html = renderer.generate_full_document(document, theme: theme)
      expect(html.scan("Copyright holder").size).to eq(1)
    end
  end

  it "rejects an unknown or unavailable placement instead of silently losing content" do
    theme = Metanorma::Html::Theme.new(boilerplate_placement: "missing")
    expect { renderer.generate_full_document(document, theme: theme) }.to raise_error(ArgumentError, /Unknown boilerplate/)
    theme.boilerplate_placement = "intro"
    expect { renderer.generate_full_document(document, theme: theme) }.to raise_error(ArgumentError, /requires a template/)
  end

  it "preserves cover notes until a root renderer adopts the front matter hook" do
    note = Metanorma::Document::Components::Blocks::NoteBlock.from_xml('<note coverpage="true"><p>Keep this note</p></note>')
    renderer.theme = Metanorma::Html::Theme.new(intro_template: "intro.liquid")
    expect(renderer.render(note)).to include("Keep this note")
  end

  it "preserves the shared cover and boilerplate when no slots are configured" do
    html = renderer.generate_full_document(document)
    expect(html).to include('class="title-section"', "Content", "Copyright holder", "Cover note")
  end
end
