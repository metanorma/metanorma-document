# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Blocks do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads BasicBlock" do
      expect(defined?(Metanorma::Document::Components::Blocks::BasicBlock)).to be_truthy
    end

    it "autoloads BasicBlockNoNotes" do
      expect(defined?(Metanorma::Document::Components::Blocks::BasicBlockNoNotes)).to be_truthy
    end

    it "autoloads NoteBlock" do
      expect(defined?(Metanorma::Document::Components::Blocks::NoteBlock)).to be_truthy
    end
  end
end
