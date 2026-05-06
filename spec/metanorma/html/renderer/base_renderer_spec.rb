# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::BaseRenderer do
  let(:renderer) { described_class.new }

  describe "#escape_html" do
    it "escapes ampersands" do
      renderer.send(:escape_html, "a&b").should eq("a&amp;b")
    end

    it "escapes angle brackets" do
      renderer.send(:escape_html, "<em>").should eq("&lt;em&gt;")
    end

    it "escapes double quotes" do
      renderer.send(:escape_html, 'a "b" c').should eq("a &quot;b&quot; c")
    end

    it "handles nil" do
      renderer.send(:escape_html, nil).should eq("")
    end
  end

  describe "#element_attrs" do
    it "builds attribute string" do
      result = renderer.send(:element_attrs, id: "foo", class: "bar")
      result.should include('id="foo"')
      result.should include('class="bar"')
    end

    it "skips nil values" do
      result = renderer.send(:element_attrs, id: "foo", class: nil)
      result.should include('id="foo"')
      result.should_not include("class")
    end

    it "skips empty strings" do
      result = renderer.send(:element_attrs, id: "", class: "bar")
      result.should_not include("id=")
      result.should include('class="bar"')
    end

    it "skips false values" do
      result = renderer.send(:element_attrs, disabled: false)
      result.should be_empty
    end
  end

  describe "#html_class_for_span" do
    it "maps known XML roles to HTML class names" do
      renderer.send(:html_class_for_span, "boldtitle").should eq("title-text")
      renderer.send(:html_class_for_span, "citesec").should eq("xref-section")
      renderer.send(:html_class_for_span, "fmt-obligation").should eq("obligation-text")
    end

    it "generates prefixed class for unknown roles" do
      renderer.send(:html_class_for_span, "custom-thing").should eq("span-custom-thing")
    end
  end

  describe "SPAN_ROLE_CLASSES" do
    it "is frozen" do
      described_class::SPAN_ROLE_CLASSES.should be_frozen
    end

    it "maps all expected XML roles" do
      expected_keys = %w[boldtitle citesec citefig citetbl citeapp
                         fmt-element-name fmt-obligation fmt-autonum-delim
                         std_publisher stdpublisher stddocNumber stddocTitle
                         stddocPartNumber stdyear smallcap date]
      expected_keys.each do |key|
        described_class::SPAN_ROLE_CLASSES.should have_key(key),
                                                  "Expected SPAN_ROLE_CLASSES to have key #{key}"
      end
    end
  end

  describe "BLOCK_TYPES" do
    it "is a frozen Set" do
      described_class::BLOCK_TYPES.should be_frozen
      described_class::BLOCK_TYPES.should be_a(Set)
    end

    it "includes all block element types" do
      described_class::BLOCK_TYPES.should include(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
      described_class::BLOCK_TYPES.should include(Metanorma::Document::Components::Tables::TableBlock)
      described_class::BLOCK_TYPES.should include(Metanorma::Document::Components::Blocks::NoteBlock)
    end
  end
end
