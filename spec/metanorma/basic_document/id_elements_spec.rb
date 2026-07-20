# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::IdElements do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads AltSource" do
      expect(defined?(Metanorma::Document::Components::IdElements::AltSource)).to be_truthy
    end

    it "autoloads Audio" do
      expect(defined?(Metanorma::Document::Components::IdElements::Audio)).to be_truthy
    end

    it "autoloads Bookmark" do
      expect(defined?(Metanorma::Document::Components::IdElements::Bookmark)).to be_truthy
    end

    it "autoloads IdElement" do
      expect(defined?(Metanorma::Document::Components::IdElements::IdElement)).to be_truthy
    end

    it "autoloads Image" do
      expect(defined?(Metanorma::Document::Components::IdElements::Image)).to be_truthy
    end

    it "autoloads Media" do
      expect(defined?(Metanorma::Document::Components::IdElements::Media)).to be_truthy
    end

    it "autoloads MediaType" do
      expect(defined?(Metanorma::Document::Components::IdElements::MediaType)).to be_truthy
    end

    it "autoloads Video" do
      expect(defined?(Metanorma::Document::Components::IdElements::Video)).to be_truthy
    end
  end
end
