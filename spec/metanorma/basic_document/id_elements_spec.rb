# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::IdElements do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads AltSource" do
      defined?(Metanorma::Document::Components::IdElements::AltSource).should be_truthy
    end

    it "autoloads Audio" do
      defined?(Metanorma::Document::Components::IdElements::Audio).should be_truthy
    end

    it "autoloads Bookmark" do
      defined?(Metanorma::Document::Components::IdElements::Bookmark).should be_truthy
    end

    it "autoloads IdElement" do
      defined?(Metanorma::Document::Components::IdElements::IdElement).should be_truthy
    end

    it "autoloads Image" do
      defined?(Metanorma::Document::Components::IdElements::Image).should be_truthy
    end

    it "autoloads Media" do
      defined?(Metanorma::Document::Components::IdElements::Media).should be_truthy
    end

    it "autoloads MediaType" do
      defined?(Metanorma::Document::Components::IdElements::MediaType).should be_truthy
    end

    it "autoloads Video" do
      defined?(Metanorma::Document::Components::IdElements::Video).should be_truthy
    end
  end
end
