# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::Handlers::Inline, ".extract_rich_html" do
  def parse_title(xml)
    Metanorma::Document::Components::Inline::TitleWithAnnotationElement.from_xml(xml)
  end

  it "returns empty string for nil" do
    expect(described_class.extract_rich_html(nil)).to eq("")
  end

  it "extracts plain text title unchanged" do
    title = parse_title("<title>Plain title</title>")
    result = described_class.extract_rich_html(title)
    expect(result).to eq("Plain title")
  end

  it "escapes HTML entities in plain text" do
    title = parse_title("<title>A &lt; B &amp; C</title>")
    result = described_class.extract_rich_html(title)
    expect(result).to include("A &lt; B &amp; C")
  end

  describe "inline formatting tags" do
    it "extracts em as em tag" do
      title = parse_title("<title>Some <em>important</em> text</title>")
      result = described_class.extract_rich_html(title)
      expect(result).to include("<em>important</em>")
      expect(result).to include("Some")
      expect(result).to include("text")
    end

    it "extracts strong as strong tag" do
      title = parse_title("<title>Some <strong>bold</strong> text</title>")
      result = described_class.extract_rich_html(title)
      expect(result).to include("<strong>bold</strong>")
    end

    it "extracts sub as sub tag" do
      title = parse_title("<title>H<sub>2</sub>O</title>")
      result = described_class.extract_rich_html(title)
      expect(result).to include("<sub>2</sub>")
      expect(result).to include("H")
      expect(result).to include("O")
    end

    it "extracts sup as sup tag" do
      title = parse_title("<title>x<sup>2</sup></title>")
      result = described_class.extract_rich_html(title)
      expect(result).to include("<sup>2</sup>")
    end

    it "extracts tt as code tag" do
      title = parse_title("<title>Use <tt>monospace</tt> font</title>")
      result = described_class.extract_rich_html(title)
      expect(result).to include("<code>monospace</code>")
    end

    it "extracts underline as u tag" do
      title = parse_title("<title><underline>underlined</underline> text</title>")
      result = described_class.extract_rich_html(title)
      expect(result).to include("<u>underlined</u>")
    end

    it "extracts strike as s tag" do
      title = parse_title("<title><strike>deleted</strike> text</title>")
      result = described_class.extract_rich_html(title)
      expect(result).to include("<s>deleted</s>")
    end

    it "extracts smallcap as span tag with font-variant style" do
      title = parse_title("<title><smallcap>SC</smallcap> text</title>")
      result = described_class.extract_rich_html(title)
      expect(result).to include('<span style="font-variant: small-caps">SC</span>')
    end
  end

  describe "cross-reference and link elements" do
    it "extracts xref as HTML link" do
      title = parse_title(<<~XML)
        <title>See <xref target="sec-3.5.12">3.5.12</xref> for details</title>
      XML
      result = described_class.extract_rich_html(title)
      expect(result).to include('<a href="#sec-3.5.12">')
      expect(result).to include("3.5.12")
      expect(result).to include("for details")
    end

    it "extracts link as HTML anchor" do
      title = parse_title("<title>See <link target=\"https://example.com\">example</link></title>")
      result = described_class.extract_rich_html(title)
      expect(result).to include('<a href="https://example.com">')
      expect(result).to include("example")
    end

    it "escapes href values in links" do
      title = parse_title("<title><link target=\"https://x.co/a&amp;b\">t</link></title>")
      result = described_class.extract_rich_html(title)
      expect(result).to include('href="https://x.co/a&amp;b"')
    end
  end

  describe "stem (math) elements" do
    it "extracts stem as stem span" do
      title = parse_title(<<~XML)
        <title>Value (<stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mi>D</mi><mtext>min</mtext></msub></math></stem>) test</title>
      XML
      result = described_class.extract_rich_html(title)
      expect(result).to include('<span class="stem">')
      expect(result).to include("<math")
      expect(result).to include("D")
    end
  end

  describe "mixed content" do
    it "extracts mixed inline content in correct order" do
      title = parse_title(<<~XML)
        <title>A <em>B</em> C <xref target="s1">1</xref> D</title>
      XML
      result = described_class.extract_rich_html(title)
      expect(result).to include("A <em>B</em> C <a href=\"#s1\">1</a> D")
    end

    it "handles deeply nested text in single element" do
      title = parse_title("<title><em>bold and italic</em></title>")
      result = described_class.extract_rich_html(title)
      expect(result).to include("<em>")
      expect(result).to include("bold and italic")
    end
  end
end
