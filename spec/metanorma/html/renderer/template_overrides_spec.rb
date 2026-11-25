# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"

RSpec.describe "Flavor Liquid template hooks" do
  after { FileUtils.remove_entry(template_root) }

  def directory(name)
    FileUtils.mkdir_p(File.join(template_root, name)).first
  end

  def write_template(dir, name, content)
    File.write(File.join(dir, name), content)
  end

  def renderer_class(paths, parent = Metanorma::Html::BaseRenderer)
    Class.new(parent) do
      define_method(:template_directories) { paths + super() }
    end
  end

  let(:template_root) { Dir.mktmpdir("template-hooks") }
  let(:flavor_dir) { directory("flavor") }
  let(:theme_dir) { directory("theme") }
  let(:renderer) { renderer_class([flavor_dir]).new }
  let(:paragraph) do
    Metanorma::Document::Components::Paragraphs::ParagraphBlock.new
  end

  it "uses a flavor override through the composed paragraph renderer" do
    write_template(flavor_dir, "_paragraph.html.liquid",
                   '<p class="flavor"{{ attrs }}>{{ content }}</p>')
    expect(renderer.render_paragraph(paragraph)).to include('<p class="flavor">')
  end

  it "keeps the shared template when no override exists" do
    expect(renderer.render_paragraph(paragraph)).to include("<p>")
  end

  it "gives organization theme templates priority over flavor templates" do
    write_template(flavor_dir, "_paragraph.html.liquid", "flavor")
    FileUtils.mkdir_p(File.join(theme_dir, "templates"))
    write_template(File.join(theme_dir, "templates"), "_paragraph.html.liquid",
                   "theme")
    theme = Metanorma::Html::Theme.new
    theme.theme_dir = theme_dir
    renderer.theme = theme
    expect(renderer.render_paragraph(paragraph)).to eq("theme")
  end

  it "lets taste subclasses prepend their templates and inherit other overrides" do
    taste_dir = directory("taste")
    write_template(taste_dir, "_paragraph.html.liquid", "taste")
    write_template(flavor_dir, "_paragraph.html.liquid", "flavor")
    write_template(flavor_dir, "_note.html.liquid", "parent note")
    taste = renderer_class([taste_dir], renderer.class).new
    expect(taste.render_paragraph(paragraph)).to eq("taste")
    expect(taste.render_liquid("_note.html.liquid", {})).to eq("parent note")
  end

  it "resolves nested render partials through the same search path" do
    write_template(flavor_dir, "_paragraph.html.liquid",
                   "{% render 'outer', value: content %}")
    write_template(flavor_dir, "_outer.html.liquid",
                   "{% render 'inner', value: value %}")
    write_template(flavor_dir, "_inner.html.liquid", "custom {{ value }}")
    expect(renderer.render_liquid("_paragraph.html.liquid", content: "text"))
      .to eq("custom text")
  end

  it "resolves include partials through the same search path" do
    write_template(flavor_dir, "_paragraph.html.liquid", "{% include 'inner' %}")
    write_template(flavor_dir, "_inner.html.liquid", "custom {{ content }}")
    expect(renderer.render_liquid("_paragraph.html.liquid", content: "text"))
      .to eq("custom text")
  end

  it "supports partials in subdirectories" do
    FileUtils.mkdir_p(File.join(flavor_dir, "details"))
    write_template(flavor_dir, "_paragraph.html.liquid",
                   "{% render 'details/branding' %}")
    write_template(File.join(flavor_dir, "details"), "_branding.html.liquid", "brand")
    expect(renderer.render_paragraph(paragraph)).to eq("brand")
  end

  it "lets nested partials fall back to shared templates" do
    write_template(flavor_dir, "_paragraph.html.liquid",
                   "{% render 'doc_title', title: 'Title' %}")
    expect(renderer.render_paragraph(paragraph)).to include("Title")
  end

  it "resolves theme partials before flavor partials" do
    write_template(flavor_dir, "_paragraph.html.liquid", "{% render 'branding' %}")
    write_template(flavor_dir, "_branding.html.liquid", "flavor branding")
    theme = Metanorma::Html::Theme.new
    theme.theme_dir = theme_dir
    FileUtils.mkdir_p(File.join(theme_dir, "templates"))
    write_template(File.join(theme_dir, "templates"), "_branding.html.liquid",
                   "theme branding")
    renderer.theme = theme
    expect(renderer.render_paragraph(paragraph)).to eq("theme branding")
  end

  it "inherits entry templates when a taste overrides only one partial" do
    parent_dir = directory("parent/templates")
    child_dir = directory("child/templates")
    write_template(parent_dir, "_paragraph.html.liquid",
                   "{% render 'branding' %}: {% render 'inherited' %}")
    write_template(parent_dir, "_branding.html.liquid", "parent branding")
    write_template(parent_dir, "_inherited.html.liquid", "parent content")
    write_template(child_dir, "_branding.html.liquid", "taste branding")
    write_template(flavor_dir, "_paragraph.html.liquid", "flavor fallback")
    write_template(flavor_dir, "_inherited.html.liquid", "flavor content")
    File.write(File.join(template_root, "parent/theme.yaml"), {}.to_yaml)
    File.write(File.join(template_root, "child/theme.yaml"),
               { "extends" => "parent" }.to_yaml)
    stub_const("Metanorma::Html::Theme::THEMES_DIR", template_root)
    renderer.theme = Metanorma::Html::Theme.load(:child)

    expect(renderer.render_paragraph(paragraph))
      .to eq("taste branding: parent content")
  end

  it "uses a child entry template with inherited include partials" do
    parent_dir = directory("parent/templates")
    child_dir = directory("child/templates")
    write_template(child_dir, "_paragraph.html.liquid", "{% include 'branding' %}")
    write_template(parent_dir, "_branding.html.liquid", "parent branding")
    write_template(flavor_dir, "_branding.html.liquid", "flavor fallback")
    theme = Metanorma::Html::Theme.new
    theme.theme_dir = File.dirname(child_dir)
    theme.inherited_theme_dirs = [File.dirname(parent_dir)]
    renderer.theme = theme

    expect(renderer.render_paragraph(paragraph)).to eq("parent branding")
  end

  it "does not leak partials between renderers sharing a cached entry template" do
    shared_dir = directory("shared")
    other_dir = directory("other")
    write_template(shared_dir, "_paragraph.html.liquid", "{% render 'branding' %}")
    write_template(flavor_dir, "_branding.html.liquid", "first")
    write_template(other_dir, "_branding.html.liquid", "second")
    first = renderer_class([flavor_dir, shared_dir]).new
    second = renderer_class([other_dir, shared_dir]).new
    expect(first.render_paragraph(paragraph)).to eq("first")
    expect(second.render_paragraph(paragraph)).to eq("second")
    expect(first.render_paragraph(paragraph)).to eq("first")
  end

  it "leaves Liquid's global file system unchanged" do
    file_system = Liquid::Environment.default.file_system
    renderer.render_paragraph(paragraph)
    expect(Liquid::Environment.default.file_system).to equal(file_system)
  end

  it "reports a missing entry template" do
    expect { renderer.render_liquid("missing.html.liquid", {}) }
      .to raise_error(Liquid::FileSystemError, /No such template/)
  end

  it "rejects traversal and absolute paths" do
    ["../secret.html.liquid", "/secret.html.liquid"].each do |name|
      expect { renderer.render_liquid(name, {}) }
        .to raise_error(Liquid::FileSystemError, /Invalid template name/)
    end
  end

  it "rejects partial traversal" do
    resolver = Metanorma::Html::TemplateResolver.new([flavor_dir])
    expect { resolver.read_template_file("../secret") }
      .to raise_error(Liquid::FileSystemError, /Invalid partial name/)
  end

  it "rejects symlinks escaping a template directory" do
    outside = File.join(template_root, "outside.html.liquid")
    File.write(outside, "outside")
    File.symlink(outside, File.join(flavor_dir, "_paragraph.html.liquid"))
    expect { renderer.render_paragraph(paragraph) }
      .to raise_error(Liquid::FileSystemError, /outside directory/)
  end
end
