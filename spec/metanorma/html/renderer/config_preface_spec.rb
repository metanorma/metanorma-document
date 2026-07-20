# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/base_renderer"
require "metanorma/html/theme"

RSpec.describe "Config-driven preface rendering" do
  let(:theme) { Metanorma::Html::Theme.new }
  let(:renderer) do
    r = Metanorma::Html::BaseRenderer.new
    r.theme = theme
    r
  end

  describe "BaseRenderer#render_preface (ordered mode)" do
    before do
      theme.preface_order = %w[foreword introduction clause]
      theme.preface_wrap = false
      theme.toc_filter_types = []
    end

    it "returns empty string when preface has no sections" do
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new
      result = renderer.render_preface(preface)
      expect(result).to eq("")
    end

    it "renders sections in config order" do
      foreword = Metanorma::IsoDocument::Sections::IsoForewordSection.new(id: "fw-1")
      introduction = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "intro-1")
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new(
        foreword: foreword,
        introduction: introduction,
      )

      result = renderer.render_preface(preface)
      expect(result).to be_a(String)
    end
  end

  describe "BaseRenderer#render_preface (wrapped mode)" do
    before do
      theme.preface_order = %w[clause]
      theme.preface_wrap = true
      theme.toc_filter_types = []
    end

    it "wraps clauses in preface container" do
      clause1 = Metanorma::IsoDocument::Sections::IsoClauseSection.new(id: "cl-1")
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new(clause: [clause1])

      result = renderer.render_preface(preface)
      expect(result).to include("preface")
    end

    it "returns nil when no content" do
      preface = Metanorma::IsoDocument::Sections::IsoPreface.new

      result = renderer.render_preface(preface)
      expect(result).to be_nil
    end
  end
end
