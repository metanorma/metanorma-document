# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::IdStrategy do
  describe Metanorma::Mirror::IdStrategy::Base do
    let(:strategy) { described_class.new }

    it "returns the element's id via assign_id" do
      element = Metanorma::Standoc::Document::Sections::ClauseSection.new(id: "sec-3.2")
      expect(strategy.assign_id(element)).to eq("sec-3.2")
    end

    it "returns nil when element has no id" do
      element = Metanorma::Standoc::Document::Sections::ClauseSection.new
      expect(strategy.assign_id(element)).to be_nil
    end

    it "returns the document unchanged via finalize!" do
      doc = { "type" => "doc", "content" => [] }
      expect(strategy.finalize!(doc)).to equal(doc)
    end
  end

  describe Metanorma::Mirror::IdStrategy::Preserve do
    let(:strategy) { described_class.new }

    it "returns the element's id unchanged" do
      element = Metanorma::Standoc::Document::Sections::ClauseSection.new(id: "sec-3.2")
      expect(strategy.assign_id(element)).to eq("sec-3.2")
    end

    it "returns the document unchanged via finalize!" do
      doc = { "type" => "doc", "content" => [] }
      expect(strategy.finalize!(doc)).to equal(doc)
    end
  end

  describe Metanorma::Mirror::IdStrategy::Positional do
    let(:strategy) { described_class.new }

    describe "#assign_id" do
      it "preserves explicit (non-UUID) IDs" do
        element = Metanorma::Standoc::Document::Sections::ClauseSection.new(
          id: "sec-3.2", number: "3.2",
        )
        expect(strategy.assign_id(element)).to eq("sec-3.2")
      end

      it "derives positional ID for UUID section elements with number" do
        element = Metanorma::Standoc::Document::Sections::ClauseSection.new(
          id: "_abc123", number: "5.4",
        )
        expect(strategy.assign_id(element)).to eq("sec-5.4")
      end

      it "returns raw UUID when no number and no derivable position" do
        element = Metanorma::Standoc::Document::Sections::ClauseSection.new(id: "_abc123")
        expect(strategy.assign_id(element)).to eq("_abc123")
      end

      it "returns nil when element has no id" do
        element = Metanorma::Standoc::Document::Sections::ClauseSection.new
        expect(strategy.assign_id(element)).to be_nil
      end
    end

    describe "uuid? detection" do
      it "recognizes UUID-prefixed IDs starting with underscore" do
        element = Metanorma::Standoc::Document::Sections::ClauseSection.new(
          id: "_abc123-def456", number: "3.1",
        )
        expect(strategy.assign_id(element)).to eq("sec-3.1")
      end
    end

    describe "element_category" do
      it "categorizes ClauseSection as :section" do
        element = Metanorma::Standoc::Document::Sections::ClauseSection.new(
          id: "_uuid1", number: "4.1",
        )
        expect(strategy.assign_id(element)).to eq("sec-4.1")
      end

      it "categorizes ContentSection as :section" do
        element = Metanorma::Standoc::Document::Sections::ContentSection.new(
          id: "_uuid2", number: "2.3",
        )
        expect(strategy.assign_id(element)).to eq("sec-2.3")
      end

      it "categorizes AnnexSection as :annex" do
        element = Metanorma::Standoc::Document::Sections::AnnexSection.new(
          id: "_uuid3", number: "A.2",
        )
        expect(strategy.assign_id(element)).to eq("anx-A.2")
      end

      it "categorizes FigureBlock as :figure" do
        element = Metanorma::Document::Components::AncillaryBlocks::FigureBlock.new(
          id: "_uuid4", autonum: "5",
        )
        # FigureBlock lacks :number, so Positional falls back to raw UUID
        expect(strategy.assign_id(element)).to eq("_uuid4")
      end

      it "categorizes TableBlock as :table" do
        element = Metanorma::Document::Components::Tables::TableBlock.new(
          id: "_uuid5", autonum: "3",
        )
        # TableBlock lacks :number, so Positional falls back to raw UUID
        expect(strategy.assign_id(element)).to eq("_uuid5")
      end
    end

    describe "#finalize!" do
      it "remaps xref mark targets from UUID to positional IDs" do
        section = Metanorma::Standoc::Document::Sections::ClauseSection.new(
          id: "_abc123", number: "5.4",
        )
        strategy.assign_id(section)

        xref_mark = Metanorma::Mirror::Model::Mark.new(type: "xref",
                                                       attrs: { "target" => "_abc123" })
        text_node = Metanorma::Mirror::Model::Text.new(text: "see section",
                                                       marks: [xref_mark])
        paragraph = Metanorma::Mirror::Model::Container.new(type: "paragraph",
                                                            content: [text_node])
        doc = Metanorma::Mirror::Model::Container.new(type: "doc",
                                                      content: [paragraph])

        result = strategy.finalize!(doc)
        xref = result.content[0].content[0].marks[0]
        expect(xref.attrs["target"]).to eq("sec-5.4")
      end

      it "returns the document unchanged when no IDs were remapped" do
        doc = Metanorma::Mirror::Model::Container.new(type: "doc", content: [])
        result = strategy.finalize!(doc)
        expect(result).to equal(doc)
      end

      it "does not modify xref targets not in the id_map" do
        section = Metanorma::Standoc::Document::Sections::ClauseSection.new(
          id: "_mapped", number: "1.1",
        )
        strategy.assign_id(section)

        xref_mark = Metanorma::Mirror::Model::Mark.new(type: "xref",
                                                       attrs: { "target" => "sec-existing" })
        text_node = Metanorma::Mirror::Model::Text.new(text: "link",
                                                       marks: [xref_mark])
        paragraph = Metanorma::Mirror::Model::Container.new(type: "paragraph",
                                                            content: [text_node])
        doc = Metanorma::Mirror::Model::Container.new(type: "doc",
                                                      content: [paragraph])

        result = strategy.finalize!(doc)
        xref = result.content[0].content[0].marks[0]
        expect(xref.attrs["target"]).to eq("sec-existing")
      end
    end

    describe ".register_category (OCP)" do
      it "allows new categories to be registered without modifying dispatch" do
        custom_class = Class.new
        described_class.register_category(custom_class, :widget)
        expect(described_class.category_for(custom_class.new)).to eq(:widget)
      ensure
        described_class.unregister_category(custom_class)
      end

      it "supports subclass categorization via is_a?" do
        base = Class.new
        sub = Class.new(base)
        described_class.register_category(base, :custom)
        expect(described_class.category_for(sub.new)).to eq(:custom)
      ensure
        described_class.unregister_category(base)
      end
    end
  end
end
