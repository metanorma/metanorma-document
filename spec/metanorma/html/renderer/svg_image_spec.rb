# frozen_string_literal: true

require "spec_helper"
require "metanorma/html/generator"

RSpec.describe "SVG image capture and rendering" do
  describe Metanorma::Document::Components::IdElements::Image do
    describe "inline SVG capture via map_element raw: :element" do
      let(:svg_xml) do
        <<~XML
          <image id="fig1" src="test.png" height="100" width="200" alt="Test">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
              <rect x="0" y="0" width="100" height="100" fill="red"/>
            </svg>
          </image>
        XML
      end

      it "captures the full SVG element as inline_svg" do
        image = described_class.from_xml(svg_xml)
        image.inline_svg.should include("<svg")
        image.inline_svg.should include("</svg>")
      end

      it "preserves SVG namespace attribute" do
        image = described_class.from_xml(svg_xml)
        image.inline_svg.should include("xmlns=\"http://www.w3.org/2000/svg\"")
      end

      it "preserves SVG child elements" do
        image = described_class.from_xml(svg_xml)
        image.inline_svg.should include("<rect")
        image.inline_svg.should include("fill=\"red\"")
      end

      it "preserves SVG element attributes" do
        image = described_class.from_xml(svg_xml)
        image.inline_svg.should include("viewBox")
      end

      it "parses image attributes normally alongside SVG" do
        image = described_class.from_xml(svg_xml)
        image.source.should eq("test.png")
        image.height.should eq("100")
        image.width.should eq("200")
        image.alt.should eq("Test")
      end
    end

    describe "image without SVG" do
      let(:plain_xml) do
        '<image id="fig2" src="photo.jpg" height="300" width="400"/>'
      end

      it "has nil inline_svg" do
        image = described_class.from_xml(plain_xml)
        image.inline_svg.should be_nil
      end

      it "parses image attributes" do
        image = described_class.from_xml(plain_xml)
        image.source.should eq("photo.jpg")
        image.height.should eq("300")
      end
    end
  end

  describe "SVG image rendering through HTML pipeline" do
    let(:svg_xml) do
      <<~XML
        <image id="fig1" src="test.png" height="100" width="200" alt="Test">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
            <rect x="0" y="0" width="100" height="100" fill="red"/>
          </svg>
        </image>
      XML
    end

    it "renders inline SVG as base64 data URI in img tag" do
      image = Metanorma::Document::Components::IdElements::Image.from_xml(svg_xml)
      renderer = Metanorma::Html::BaseRenderer.new
      html = renderer.render_image(image)
      html.should include("data:image/svg+xml;base64,")
      html.should include("<img")
    end

    it "does not include file source when SVG is present" do
      image = Metanorma::Document::Components::IdElements::Image.from_xml(svg_xml)
      renderer = Metanorma::Html::BaseRenderer.new
      html = renderer.render_image(image)
      html.should_not include("test.png")
    end

    it "renders regular images with file source" do
      plain_xml = '<image id="fig2" src="photo.jpg" height="300"/>'
      image = Metanorma::Document::Components::IdElements::Image.from_xml(plain_xml)
      renderer = Metanorma::Html::BaseRenderer.new
      html = renderer.render_image(image)
      html.should include("photo.jpg")
      html.should_not include("data:")
    end

    it "preserves image id in rendered output" do
      image = Metanorma::Document::Components::IdElements::Image.from_xml(svg_xml)
      renderer = Metanorma::Html::BaseRenderer.new
      html = renderer.render_image(image)
      html.should include("fig1")
    end
  end
end
