# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/base_renderer"

RSpec.describe "Liquid templates" do
  TEMPLATE_DIR = File.expand_path("../../../../lib/metanorma/html/templates", __dir__)

  def render_template(name, assigns)
    path = File.join(TEMPLATE_DIR, "_#{name}.html.liquid")
    template = Liquid::Template.parse(File.read(path))
    template.render(assigns)
  end

  describe "_heading.html.liquid" do
    it "renders an h2 with content" do
      html = render_template("heading", {
        "tag" => "h2",
        "class_attr" => ' class="foreword-title"',
        "content" => "Foreword",
      })
      html.should include("<h2")
      html.should include("foreword-title")
      html.should include("Foreword")
      html.should include("</h2>")
    end

    it "renders heading without class" do
      html = render_template("heading", {
        "tag" => "h3",
        "class_attr" => "",
        "content" => "Title",
      })
      html.should include("<h3>")
      html.should include("Title")
    end
  end

  describe "_element.html.liquid" do
    it "renders a div with content" do
      html = render_template("element", {
        "tag" => "div",
        "extra_attrs" => ' class="note-block"',
        "content" => "Note text",
      })
      html.should include('<div class="note-block"')
      html.should include("Note text")
    end
  end

  describe "_paragraph.html.liquid" do
    it "renders a p with content" do
      html = render_template("paragraph", {
        "attrs" => ' id="p1"',
        "content" => "Para text",
      })
      html.should include('<p id="p1">')
      html.should include("Para text")
    end
  end

  describe "_link.html.liquid" do
    it "renders an anchor with content" do
      html = render_template("link", {
        "attrs" => ' href="https://example.com"',
        "content" => "Example",
      })
      html.should include('<a href="https://example.com"')
      html.should include("Example")
    end

    it "renders anchor with display_text when no content" do
      html = render_template("link", {
        "attrs" => ' href="https://example.com"',
        "content" => nil,
        "display_text" => "Display",
      })
      html.should include("Display")
    end
  end

  describe "_image.html.liquid" do
    it "renders an img tag" do
      html = render_template("image", {
        "attrs" => ' src="photo.png" alt="Photo"',
      })
      html.should include("<img")
      html.should include('src="photo.png"')
      html.should include(" />")
    end
  end

  describe "_list.html.liquid" do
    it "renders an unordered list" do
      html = render_template("list", {
        "list_tag" => "ul",
        "attrs" => "",
        "items" => ["<li>A</li>", "<li>B</li>"],
      })
      html.should include("<ul>")
      html.should include("<li>A</li>")
    end

    it "renders an ordered list" do
      html = render_template("list", {
        "list_tag" => "ol",
        "attrs" => "",
        "items" => ["<li>1</li>"],
      })
      html.should include("<ol>")
    end
  end

  describe "_br.html.liquid" do
    it "renders a br tag" do
      html = render_template("br", {})
      html.should include("<br />")
    end
  end

  describe "_bookmark.html.liquid" do
    it "renders a bookmark span" do
      html = render_template("bookmark", { "id" => "bm-1" })
      html.should include('id="bm-1"')
    end
  end

  describe "_table.html.liquid" do
    it "renders a table with caption" do
      html = render_template("table", {
        "attrs" => ' id="tab-1"',
        "caption" => "Table 1",
        "colgroup_html" => nil,
        "thead_html" => "<thead><tr><th>H</th></tr></thead>",
        "tbody_html" => "<tbody><tr><td>D</td></tr></tbody>",
        "tfoot_html" => nil,
      })
      html.should include("<table")
      html.should include("Table 1")
      html.should include("<th>H</th>")
    end
  end

  describe "_ref_date.html.liquid" do
    it "renders date reference with prefix" do
      html = render_template("ref_date", { "prefix" => ":", "year" => "2024" })
      html.should include(":")
      html.should include("2024")
      html.should include("ref-year")
    end
  end

  describe "_term_number.html.liquid" do
    it "renders term number" do
      html = render_template("term_number", { "content" => "3.1" })
      html.should include("3.1")
      html.should include("term-number")
    end
  end

  describe "_section.html.liquid" do
    it "renders a section with content" do
      html = render_template("section", {
        "attrs" => ' class="clause"',
        "title" => "<h2>Title</h2>",
        "content" => "Section body",
        "notes" => nil,
      })
      html.should include("clause")
      html.should include("Title")
      html.should include("Section body")
    end
  end

  describe "template file parseability" do
    Dir.glob(File.join(TEMPLATE_DIR, "_*.html.liquid")).each do |path|
      name = File.basename(path, ".liquid")

      it "#{name} is parseable Liquid" do
        parsed = Liquid::Template.parse(File.read(path))
        parsed.should_not be_nil
      end
    end
  end
end
