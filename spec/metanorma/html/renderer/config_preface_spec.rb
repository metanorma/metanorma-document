# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/base_renderer"
require "metanorma/html/renderers/section_renderer"
require "metanorma/html/theme"

RSpec.describe "Config-driven preface rendering" do
  let(:theme) { Metanorma::Html::Theme.new }
  let(:renderer) do
    r = Metanorma::Html::BaseRenderer.new
    r.instance_variable_set(:@theme, theme)
    r
  end
  let(:section_renderer) { renderer.section_renderer }

  describe "SectionRenderer#render_preface (ordered mode)" do
    before do
      theme.preface_order = %w[foreword introduction clause]
      theme.preface_wrap = false
      theme.toc_filter_types = []
    end

    it "renders sections in config order" do
      foreword = Metanorma::IsoDocument::Sections::IsoForewordSection.new(id: "fw-1")
      introduction = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "intro-1")
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new(
        foreword: foreword,
        introduction: introduction,
      )

      allow(renderer).to receive(:render).and_return("")
      section_renderer.render_preface(preface)

      renderer.should have_received(:render).with(foreword).ordered
      renderer.should have_received(:render).with(introduction).ordered
    end

    it "skips sections not present in preface" do
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new

      allow(renderer).to receive(:render)
      section_renderer.render_preface(preface)

      renderer.should_not have_received(:render)
    end

    it "renders clause array when present" do
      clause1 = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "cl-1")
      clause2 = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "cl-2")
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new(clause: [clause1, clause2])

      allow(renderer).to receive(:render).and_return("")
      section_renderer.render_preface(preface)

      renderer.should have_received(:render).with(clause1, level: 1)
      renderer.should have_received(:render).with(clause2, level: 1)
    end
  end

  describe "SectionRenderer#render_preface (wrapped mode)" do
    before do
      theme.preface_order = %w[clause]
      theme.preface_wrap = true
      theme.toc_filter_types = []
    end

    it "wraps clauses in preface container" do
      clause1 = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "cl-1")
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new(clause: [clause1])

      allow(renderer).to receive(:render).and_return("")
      allow(renderer).to receive(:register_toc_entry)
      allow(renderer).to receive(:render_liquid).and_return("<div>wrapped</div>")

      section_renderer.render_preface(preface)

      renderer.should have_received(:render_liquid).with("_wrapped_preface.html.liquid", anything)
      renderer.should have_received(:register_toc_entry).with(id: "preface", level: 1, text: "Preface")
    end

    it "returns early when no content" do
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new
      allow(renderer).to receive(:render_liquid)

      section_renderer.render_preface(preface)

      renderer.should_not have_received(:render_liquid)
    end
  end

  describe "SectionRenderer#preface_clauses_filtered" do
    it "returns all clauses when no toc_filter_types" do
      clause1 = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "cl-1")
      clause2 = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "cl-2")
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new(clause: [clause1, clause2])

      result = section_renderer.preface_clauses_filtered(preface, [])
      result.should eq([clause1, clause2])
    end

    it "filters out clauses with matching type" do
      toc_clause = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "toc-1", type: "toc")
      normal_clause = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "cl-1", type: "security")
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new(clause: [toc_clause, normal_clause])

      result = section_renderer.preface_clauses_filtered(preface, %w[toc])
      result.should eq([normal_clause])
    end
  end

  describe "BaseRenderer delegation" do
    it "delegates render_preface to section_renderer" do
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new
      theme.preface_order = %w[foreword]
      theme.preface_wrap = false
      theme.toc_filter_types = []

      allow(renderer).to receive(:render)
      renderer.render_preface(preface)

      renderer.should_not have_received(:render)
    end
  end
end
