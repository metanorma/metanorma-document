# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/base_renderer"

RSpec.describe "Sub-renderer composition" do
  let(:renderer) { Metanorma::Html::BaseRenderer.new }

  describe "coordinator pattern" do
    it "creates inline_renderer" do
      renderer.inline_renderer.should be_a(Metanorma::Html::Renderers::InlineRenderer)
    end

    it "creates block_renderer" do
      renderer.block_renderer.should be_a(Metanorma::Html::Renderers::BlockRenderer)
    end

    it "creates section_renderer" do
      renderer.section_renderer.should be_a(Metanorma::Html::Renderers::SectionRenderer)
    end

    it "creates pubid_renderer" do
      renderer.pubid_renderer.should be_a(Metanorma::Html::Renderers::PubidRenderer)
    end
  end

  describe "delegation wrappers" do
    it "delegates render_basic_section to section_renderer" do
      section = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "sec-1")
      allow(renderer.section_renderer).to receive(:render_basic_section).and_return("")

      renderer.render_basic_section(section)

      renderer.section_renderer.should have_received(:render_basic_section).with(section)
    end

    it "delegates render_preface to section_renderer" do
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new
      allow(renderer.section_renderer).to receive(:render_preface).and_return("")

      renderer.render_preface(preface)

      renderer.section_renderer.should have_received(:render_preface).with(preface)
    end

    it "delegates parse_pubid to pubid_renderer" do
      allow(renderer.pubid_renderer).to receive(:parse_pubid).and_return(nil)

      renderer.parse_pubid("ISO 9001:2015")

      renderer.pubid_renderer.should have_received(:parse_pubid).with("ISO 9001:2015")
    end

    it "delegates render_ordered_content to section_renderer" do
      section = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "sec-1")
      allow(renderer.section_renderer).to receive(:render_ordered_content).and_return("")

      renderer.render_ordered_content(section, 2)

      renderer.section_renderer.should have_received(:render_ordered_content).with(section, 2)
    end
  end

  describe "theme resolution" do
    it "returns a Theme instance" do
      renderer.theme.should be_a(Metanorma::Html::Theme)
    end

    it "caches the theme" do
      first = renderer.theme
      renderer.theme.should equal(first)
    end
  end
end
