# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/standard_renderer"

RSpec.describe Metanorma::Html::StandardRenderer do
  let(:renderer) { described_class.new }

  def stub_section_renderer(renderer, **extra_stubs)
    allow(renderer).to receive_messages(
      safe_attr: nil, element_attrs: "", **extra_stubs,
    )
    allow(renderer).to receive(:tag) { |_tag, _attrs, &blk| blk.call }
    allow(renderer).to receive(:render_standard_title)
    allow(renderer).to receive(:render_standard_section_blocks)
    allow(renderer).to receive(:render_subsections)
  end

  describe "#render_section" do
    it "delegates clause sections with_subsections" do
      stub_section_renderer(renderer)
      renderer.should receive(:render_section).with(anything, hash_including(with_subsections: true))
      renderer.send(:render_clause_section, double)
    end

    it "delegates terms sections with_terms" do
      section = double(terms: [])
      stub_section_renderer(renderer)
      renderer.should receive(:render_section).with(anything, hash_including(with_terms: true))
      renderer.send(:render_terms_section, section)
    end

    it "delegates foreword with title_class" do
      stub_section_renderer(renderer)
      renderer.should receive(:render_section).with(anything, hash_including(title_class: "foreword-title"))
      renderer.send(:render_foreword_section, double)
    end
  end
end
