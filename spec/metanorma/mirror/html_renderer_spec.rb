# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"
require "metanorma/mirror/output/html_renderer"

RSpec.describe Metanorma::Mirror::Output::HtmlRenderer do
  def build_guide(*nodes)
    { "content" => nodes.map { |n| n.is_a?(Hash) ? n : n.to_h } }
  end

  def text_node(text, marks = [])
    h = { "type" => "text", "text" => text }
    h["marks"] = marks if marks.any?
    h
  end

  let(:renderer) { described_class.new(guide) }

  describe "#render" do
    context "paragraph" do
      let(:guide) { build_guide({ "type" => "paragraph", "content" => [text_node("Hello world")] }) }

      it "renders a paragraph with text" do
        html = renderer.render
        html.should include('<p class="mn-paragraph">Hello world</p>')
      end
    end

    context "paragraph with id" do
      let(:guide) do
        build_guide({
          "type" => "paragraph",
          "attrs" => { "id" => "p1" },
          "content" => [text_node("text")],
        })
      end

      it "includes id attribute" do
        html = renderer.render
        html.should include('id="p1"')
      end
    end

    context "clause with title and children" do
      let(:guide) do
        build_guide({
          "type" => "clause",
          "attrs" => { "id" => "s1", "title" => "Scope", "number" => "1" },
          "content" => [
            { "type" => "paragraph", "content" => [text_node("Content here")] },
          ],
        })
      end

      it "renders section with heading" do
        html = renderer.render
        html.should include('<section')
        html.should include("mn-clause")
        html.should include("1 Scope")
        html.should include('<p class="mn-paragraph">Content here</p>')
      end
    end

    context "bullet list" do
      let(:guide) do
        build_guide({
          "type" => "bullet_list",
          "content" => [
            { "type" => "list_item", "content" => [text_node("Item 1")] },
            { "type" => "list_item", "content" => [text_node("Item 2")] },
          ],
        })
      end

      it "renders unordered list" do
        html = renderer.render
        html.should include('<ul class="mn-bullet-list">')
        html.should include('<li class="mn-list-item">')
        html.should include("Item 1")
        html.should include("Item 2")
      end
    end

    context "ordered list" do
      let(:guide) do
        build_guide({
          "type" => "ordered_list",
          "content" => [
            { "type" => "list_item", "content" => [text_node("First")] },
          ],
        })
      end

      it "renders ordered list" do
        html = renderer.render
        html.should include('<ol class="mn-ordered-list">')
        html.should include("First")
      end
    end

    context "table" do
      let(:guide) do
        build_guide({
          "type" => "table",
          "attrs" => { "id" => "t1", "title" => "Table 1" },
          "content" => [
            {
              "type" => "table_head",
              "content" => [
                {
                  "type" => "table_row",
                  "content" => [
                    { "type" => "table_cell", "content" => [text_node("Header")] },
                  ],
                },
              ],
            },
            {
              "type" => "table_body",
              "content" => [
                {
                  "type" => "table_row",
                  "content" => [
                    { "type" => "table_cell", "content" => [text_node("Cell")] },
                  ],
                },
              ],
            },
          ],
        })
      end

      it "renders table with thead and tbody" do
        html = renderer.render
        html.should include("<thead>")
        html.should include("<tbody>")
        html.should include("<th>Header</th>")
        html.should include("<td>Cell</td>")
        html.should include("Table 1")
      end
    end

    context "admonition" do
      let(:guide) do
        build_guide({
          "type" => "admonition",
          "attrs" => { "type" => "warning" },
          "content" => [
            { "type" => "paragraph", "content" => [text_node("Be careful")] },
          ],
        })
      end

      it "renders admonition with type" do
        html = renderer.render
        html.should include("mn-admonition--warning")
        html.should include("Warning")
        html.should include("Be careful")
      end
    end

    context "sourcecode" do
      let(:guide) do
        build_guide({
          "type" => "sourcecode",
          "attrs" => { "language" => "ruby", "text" => "puts 'hello'" },
        })
      end

      it "renders code block with language" do
        html = renderer.render
        html.should include("language-ruby")
        html.should include("ruby")
        html.should include("puts 'hello'")
      end
    end

    context "figure" do
      let(:guide) do
        build_guide({
          "type" => "figure",
          "attrs" => { "title" => "My figure" },
          "content" => [
            { "type" => "image", "attrs" => { "src" => "img.png", "alt" => "alt text" } },
          ],
        })
      end

      it "renders figure with image and caption" do
        html = renderer.render
        html.should include("<figure")
        html.should include('<img src="img.png" alt="alt text"')
        html.should include("<figcaption>My figure</figcaption>")
      end
    end

    context "definition list" do
      let(:guide) do
        build_guide({
          "type" => "dl",
          "content" => [
            { "type" => "dt", "content" => [text_node("term1")] },
            { "type" => "dd", "content" => [
              { "type" => "paragraph", "content" => [text_node("definition")] },
            ] },
          ],
        })
      end

      it "renders definition list" do
        html = renderer.render
        html.should include('<dl class="mn-definition-list">')
        html.should include('<dt class="mn-dt">term1</dt>')
        html.should include('<dd class="mn-dd">')
      end
    end
  end

  describe "inline marks" do
    def render_inline(marks)
      guide = build_guide({
        "type" => "paragraph",
        "content" => [text_node("text", marks)],
      })
      described_class.new(guide).render
    end

    it "renders emphasis mark" do
      html = render_inline([{ "type" => "emphasis" }])
      html.should include("<em>text</em>")
    end

    it "renders strong mark" do
      html = render_inline([{ "type" => "strong" }])
      html.should include("<strong>text</strong>")
    end

    it "renders code mark" do
      html = render_inline([{ "type" => "code" }])
      html.should include("<code>text</code>")
    end

    it "renders link mark" do
      html = render_inline([{ "type" => "link", "attrs" => { "href" => "https://example.com" } }])
      html.should include('<a href="https://example.com">text</a>')
    end

    it "renders subscript mark" do
      html = render_inline([{ "type" => "subscript" }])
      html.should include("<sub>text</sub>")
    end

    it "renders superscript mark" do
      html = render_inline([{ "type" => "superscript" }])
      html.should include("<sup>text</sup>")
    end
  end

  describe "XSS escaping" do
    it "escapes HTML in text content" do
      guide = build_guide({
        "type" => "paragraph",
        "content" => [text_node('<script>alert("xss")</script>')],
      })
      html = described_class.new(guide).render
      html.should_not include("<script>")
      html.should include("&lt;script&gt;")
    end

    it "escapes HTML in attrs" do
      guide = build_guide({
        "type" => "paragraph",
        "attrs" => { "id" => '">"><script>' },
        "content" => [text_node("text")],
      })
      html = described_class.new(guide).render
      html.should_not include("<script>")
    end

    it "escapes sourcecode text" do
      guide = build_guide({
        "type" => "sourcecode",
        "attrs" => { "text" => '<img onerror="alert(1)">' },
      })
      html = described_class.new(guide).render
      html.should include("&lt;img")
      html.should include("&quot;alert(1)&quot;")
      html.should_not include("<img onerror")
    end
  end

  describe "custom renderer registration" do
    after do
      described_class.custom_node_renderers.delete("custom_type")
      described_class.custom_mark_renderers.delete("custom_mark")
    end

    it "allows custom node renderer" do
      described_class.register_node_renderer("custom_type", ->(node, renderer) {
        "<div class=\"custom\">#{renderer.send(:e, node.dig('attrs', 'value'))}</div>"
      })
      guide = build_guide({ "type" => "custom_type", "attrs" => { "value" => "test" } })
      html = described_class.new(guide).render
      html.should include('<div class="custom">test</div>')
    end

    it "allows custom mark renderer" do
      described_class.register_mark_renderer("custom_mark", ->(text, _mark) {
        "<mark>#{text}</mark>"
      })
      guide = build_guide({
        "type" => "paragraph",
        "content" => [text_node("hi", [{ "type" => "custom_mark" }])],
      })
      html = described_class.new(guide).render
      html.should include("<mark>hi</mark>")
    end
  end
end
