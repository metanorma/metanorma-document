# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

# Caption/label content carried by <fmt-name> (issue #206): the block
# dispatch had no renderer for FmtNameElement, so requirement labels and
# admonition labels were silently skipped ("no renderer registered …
# content skipped") and their text vanished from the output.
RSpec.describe "fmt-name label rendering" do
  let(:renderer) { Metanorma::Html::StandardRenderer.new }

  describe "block dispatch" do
    let(:fmt_name) do
      Metanorma::Document::Components::Inline::FmtNameElement.from_xml(
        "<fmt-name id='_r1'><span class='fmt-caption-label'>" \
        "<span class='fmt-element-name'>Recommendation</span> " \
        "<semx element='autonum' source='_r1'>5</semx>" \
        "</span></fmt-name>",
      )
    end

    it "renders the label content instead of skipping it" do
      html = renderer.render(fmt_name)
      expect(html).to include("Recommendation")
      expect(html).to include("5")
    end
  end

  describe "admonition label" do
    let(:admonition) do
      Metanorma::Document::Components::MultiParagraph::AdmonitionBlock.from_xml(
        "<admonition id='_a1' type='important'>" \
        "<fmt-name><span class='fmt-caption-label'>" \
        "<span class='fmt-element-name'>IMPORTANT</span></span></fmt-name>" \
        "<p id='_p1'>Keep the badge in sight.</p></admonition>",
      )
    end

    it "uses the fmt-name label verbatim" do
      drop = Metanorma::Html::Drops::AdmonitionDrop.from_model(
        admonition, renderer: renderer.renderer_context
      )
      expect(drop.label_html).to include("IMPORTANT")
      expect(drop.label_html).not_to include("Important</p>")
    end

    it "falls back to the capitalized type without fmt-name" do
      plain = Metanorma::Document::Components::MultiParagraph::AdmonitionBlock
        .from_xml(
          "<admonition id='_a2' type='note'>" \
          "<p id='_p2'>Plain note.</p></admonition>",
        )
      drop = Metanorma::Html::Drops::AdmonitionDrop.from_model(
        plain, renderer: renderer.renderer_context
      )
      expect(drop.label_html).to eq("Note")
    end
  end

  describe "full-document emit of the failing shape" do
    let(:xml_path) do
      File.expand_path("../../../fixtures/iso/is/document-en.presentation.xml",
                       __dir__)
    end
    let(:doc) { Metanorma::Iso::Document::Root.from_xml(File.read(xml_path)) }
    let(:html) { Metanorma::Html::Generator.generate(doc) }

    it "emits no unregistered-renderer warning for fmt-name" do
      expect { html }.not_to output(/no renderer registered for .*FmtNameElement/)
        .to_stderr
    end
  end
end
