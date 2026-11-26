# frozen_string_literal: true

require "spec_helper"
require "liquid"

RSpec.describe "Cover, header and list polish (#114)" do
  let(:root) { File.expand_path("../../../..", __dir__) }
  let(:templates) { File.join(root, "lib/metanorma/html/templates") }
  let(:cover_path) { File.join(templates, "_standard_cover.html.liquid") }

  def render(path, assigns)
    Liquid::Template.parse(File.read(path)).render(assigns)
  end

  it "keeps the draft info on one line in the cover doc id" do
    html = render(cover_path,
                  "cover" => { "docnumber_undated" => "IEC CD 17301-1 ED2",
                               "draftinfo" => "(DRAFT 2016-05-01)",
                               "tc_docnumber" => [] })
    expect(html).to include('<span class="nowrap">(DRAFT 2016-05-01)</span>')
  end

  it "humanizes a hyphenated doctype on the cover" do
    html = render(cover_path, "doctype" => "international-standard",
                              "cover" => { "tc_docnumber" => [] })
    expect(html).to include('<p class="cover-doctype">International Standard</p>')
  end

  it "separates publisher and document id in the header" do
    html = render(File.join(templates, "_header.html.liquid"),
                  "doc_publisher" => "WMO", "doc_id" => "WMO-No. 49")
    expect(html).to match(%r{header-doc-pub">WMO</span><span class="header-doc-sep"[^>]*> &middot; </span><span class="header-doc-num">WMO-No. 49})
  end

  it "omits the separator when there is no publisher prefix" do
    html = render(File.join(templates, "_header.html.liquid"),
                  "doc_id" => "ISO 17301-1")
    expect(html).not_to include("header-doc-sep")
  end

  it "styles the label and first paragraph of a labeled list inline" do
    css = File.read(File.join(root, "data/stylesheets/components/lists.css"))
    expect(css).to match(/\.mn-labeled-list > li > \.li-label \+ p\s*\{\s*display: inline/)
  end

  it "defines the nowrap rule for cover doc ids" do
    css = File.read(File.join(root, "data/stylesheets/components/cover.css"))
    expect(css).to include(".cover-doc-id .nowrap { white-space: nowrap; }")
  end
end
