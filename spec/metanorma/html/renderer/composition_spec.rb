# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/base_renderer"

RSpec.describe "Sub-renderer composition" do
  let(:renderer) { Metanorma::Html::BaseRenderer.new }

  describe "delegation to block renderer" do
    it "renders a paragraph through delegation" do
      para = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new
      result = renderer.render_paragraph(para)
      result.should include("<p>")
    end

    it "renders a note through delegation" do
      note = Metanorma::Document::Components::Blocks::NoteBlock.new
      result = renderer.render_note(note)
      result.should include("note")
    end

    it "renders semantic children through delegation" do
      model = Struct.new(:paragraphs, :ul, :ol).new(nil, nil, nil)
      renderer.render_note_children(model).should eq("")
      renderer.render_simple_children(model).should eq("")
      renderer.render_full_block_children(model).should eq("")
    end
  end

  describe "delegation to section renderer" do
    it "sorts children by displayorder" do
      children = renderer.sort_by_displayorder([])
      children.should eq([])
    end
  end

  describe "delegation to pubid renderer" do
    it "returns nil for empty pubid" do
      renderer.parse_pubid(nil).should be_nil
      renderer.parse_pubid("").should be_nil
    end

    it "returns nil for nil identifier HTML" do
      renderer.pubid_to_html(nil).should be_nil
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
