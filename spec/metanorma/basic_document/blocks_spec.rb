# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::Blocks do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads BasicBlock" do
      defined?(Metanorma::Document::Components::Blocks::BasicBlock).should be_truthy
    end

    it "autoloads BasicBlockNoNotes" do
      defined?(Metanorma::Document::Components::Blocks::BasicBlockNoNotes).should be_truthy
    end

    it "autoloads NoteBlock" do
      defined?(Metanorma::Document::Components::Blocks::NoteBlock).should be_truthy
    end
  end
end
