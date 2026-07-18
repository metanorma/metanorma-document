# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe Metanorma::Html::BaseRenderer do
  let(:renderer) { described_class.new }

  describe "#escape_html" do
    it "escapes ampersands" do
      expect(renderer.escape_html("a&b")).to eq("a&amp;b")
    end

    it "escapes angle brackets" do
      expect(renderer.escape_html("<em>")).to eq("&lt;em&gt;")
    end

    it "escapes double quotes" do
      expect(renderer.escape_html('a "b" c')).to eq("a &quot;b&quot; c")
    end

    it "handles nil" do
      expect(renderer.escape_html(nil)).to eq("")
    end
  end

  describe "#element_attrs" do
    it "builds attribute string" do
      result = renderer.element_attrs(id: "foo", class: "bar")
      expect(result).to include('id="foo"')
      expect(result).to include('class="bar"')
    end

    it "skips nil values" do
      result = renderer.element_attrs(id: "foo", class: nil)
      expect(result).to include('id="foo"')
      expect(result).not_to include("class")
    end

    it "skips empty strings" do
      result = renderer.element_attrs(id: "", class: "bar")
      expect(result).not_to include("id=")
      expect(result).to include('class="bar"')
    end

    it "skips false values" do
      result = renderer.element_attrs(disabled: false)
      expect(result).to be_empty
    end
  end

  describe "#html_class_for_span" do
    it "maps known XML roles to HTML class names" do
      expect(renderer.html_class_for_span("boldtitle")).to eq("title-text")
      expect(renderer.html_class_for_span("citesec")).to eq("xref-section")
      expect(renderer.html_class_for_span("fmt-obligation")).to eq("obligation-text")
    end

    it "generates prefixed class for unknown roles" do
      expect(renderer.html_class_for_span("custom-thing")).to eq("span-custom-thing")
    end
  end

  describe "SPAN_ROLE_CLASSES" do
    it "is frozen" do
      expect(described_class::SPAN_ROLE_CLASSES).to be_frozen
    end

    it "maps all expected XML roles" do
      expected_keys = %w[boldtitle citesec citefig citetbl citeapp
                         fmt-element-name fmt-obligation fmt-autonum-delim
                         std_publisher stdpublisher stddocNumber stddocTitle
                         stddocPartNumber stdyear smallcap date]
      expected_keys.each do |key|
        expect(described_class::SPAN_ROLE_CLASSES).to have_key(key),
                                                      "Expected SPAN_ROLE_CLASSES to have key #{key}"
      end
    end
  end

  describe "BLOCK_TYPES" do
    it "is a frozen Hash" do
      expect(described_class::BLOCK_TYPES).to be_frozen
      expect(described_class::BLOCK_TYPES).to be_a(Hash)
    end

    it "includes all block element types" do
      expect(described_class::BLOCK_TYPES).to have_key(Metanorma::Document::Components::Paragraphs::ParagraphBlock)
      expect(described_class::BLOCK_TYPES).to have_key(Metanorma::Document::Components::Tables::TableBlock)
      expect(described_class::BLOCK_TYPES).to have_key(Metanorma::Document::Components::Blocks::NoteBlock)
    end
  end

  describe "semantic block children methods" do
    let(:renderer) { described_class.new }

    it "delegates render_note_children" do
      model = Struct.new(:paragraphs, :ul, :ol).new(nil, nil, nil)
      result = renderer.render_note_children(model)
      expect(result).to eq("")
    end

    it "delegates render_simple_children" do
      model = Struct.new(:paragraphs, :ul, :ol).new(nil, nil, nil)
      result = renderer.render_simple_children(model)
      expect(result).to eq("")
    end

    it "delegates render_full_block_children" do
      model = Struct.new(:paragraphs, :ul, :ol).new(nil, nil, nil)
      result = renderer.render_full_block_children(model)
      expect(result).to eq("")
    end
  end

  describe "#render_block_children" do
    let(:renderer) { described_class.new }
    let(:list_item) do
      Metanorma::Document::Components::Lists::ListItem.new(text: "item")
    end
    let(:ul_model) do
      Metanorma::Document::Components::Lists::UnorderedList.new(
        listitem: [list_item],
      )
    end

    it "renders present child collections via the mapped method" do
      model = Struct.new(:paragraphs, :ul, :ol).new(nil, [ul_model], nil)
      output = renderer.render_block_children(model,
                                              children: { ul: :render_unordered_list })
      expect(output).to include("<ul>")
      expect(output).to include("<li>")
    end

    it "skips nil child collections" do
      model = Struct.new(:paragraphs, :ul).new(nil, nil)
      output = renderer.render_block_children(model,
                                              children: { paragraphs: :render_paragraph })
      expect(output).to be_empty
    end
  end

  describe "#safe_attr" do
    it "returns nil for a method the object does not respond to" do
      obj = Struct.new(:name).new("x")
      expect(renderer.safe_attr(obj, :missing_method)).to be_nil
    end

    it "re-raises a NoMethodError raised inside the getter" do
      obj = Object.new
      def obj.broken
        nil.no_such_method
      end
      expect { renderer.safe_attr(obj, :broken) }.to raise_error(NoMethodError)
    end
  end

  describe "#render with an unregistered node class" do
    it "warns about the unregistered class" do
      node = Struct.new(:x).new(1)
      expect { renderer.render(node) }
        .to output(/no renderer registered/).to_stderr
    end

    it "returns an empty string" do
      node = Struct.new(:x).new(1)
      expect(renderer.render(node)).to eq("")
    end

    it "does not repeat the same warning" do
      node = Struct.new(:x).new(1)
      renderer.render(node)
      expect { renderer.render(node) }.not_to output.to_stderr
    end
  end

  describe "block-dispatch registrations for inline-ish fmt classes" do
    it "renders fmt-xref-label through as mixed inline content" do
      method = renderer.lookup_dispatch(
        Metanorma::Document::Components::Inline::FmtXrefLabelElement,
        :render_registry,
      )
      expect(method).to eq(:render_block_inline_content)
    end

    it "skips fmt-title (the semantic title attribute renders instead)" do
      method = renderer.lookup_dispatch(
        Metanorma::Document::Components::Inline::FmtTitleElement,
        :render_registry,
      )
      expect(method).to eq(:render_noop)
    end

    it "skips variant-title (toc variant, not body content)" do
      method = renderer.lookup_dispatch(
        Metanorma::Document::Components::Inline::VariantTitleElement,
        :render_registry,
      )
      expect(method).to eq(:render_noop)
    end
  end

  describe "labeled lists (fmt-name markers)" do
    it "uses the presentation-XML bullet as the marker, without duplicating it" do
      model = Metanorma::Document::Components::Lists::UnorderedList.from_xml(<<~XML)
        <ul id="x1"><li><fmt-name><semx element="autonum">&#8212;</semx></fmt-name><p>item text</p></li></ul>
      XML
      output = renderer.render_unordered_list(model)
      output.should include('class="mn-labeled-list"')
      output.should include('<span class="li-label">—</span>')
      output.should include("item text")
      output.scan("—").size.should eq(1)
    end

    it "uses the presentation-XML number as the marker in ordered lists" do
      model = Metanorma::Document::Components::Lists::OrderedList.from_xml(<<~XML)
        <ol><li><fmt-name><semx element="autonum">1.</semx></fmt-name><p>first</p></li></ol>
      XML
      output = renderer.render_ordered_list(model)
      output.should include('class="mn-labeled-list"')
      output.should include('<span class="li-label">1.</span>')
      output.should include("first")
    end

    it "leaves lists without fmt-name to default browser markers" do
      model = Metanorma::Document::Components::Lists::UnorderedList.from_xml(<<~XML)
        <ul><li><p>plain</p></li></ul>
      XML
      output = renderer.render_unordered_list(model)
      output.should_not include("mn-labeled-list")
      output.should_not include("li-label")
      output.should include("plain")
    end
  end
end
