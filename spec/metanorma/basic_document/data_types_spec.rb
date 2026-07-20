# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::DataTypes do
  it "is defined" do
    expect(defined?(described_class)).to be_truthy
  end

  describe "classes" do
    it "autoloads FormattedString" do
      expect(defined?(Metanorma::Document::Components::DataTypes::FormattedString)).to be_truthy
    end

    it "autoloads Iso15924Code" do
      expect(defined?(Metanorma::Document::Components::DataTypes::Iso15924Code)).to be_truthy
    end

    it "autoloads Iso3166Code" do
      expect(defined?(Metanorma::Document::Components::DataTypes::Iso3166Code)).to be_truthy
    end

    it "autoloads Iso639Code" do
      expect(defined?(Metanorma::Document::Components::DataTypes::Iso639Code)).to be_truthy
    end

    it "autoloads Iso8601DateTime" do
      expect(defined?(Metanorma::Document::Components::DataTypes::Iso8601DateTime)).to be_truthy
    end

    it "autoloads LocalizedString" do
      expect(defined?(Metanorma::Document::Components::DataTypes::LocalizedString)).to be_truthy
    end

    it "autoloads StringFormat" do
      expect(defined?(Metanorma::Document::Components::DataTypes::StringFormat)).to be_truthy
    end

    it "autoloads Uri" do
      expect(defined?(Metanorma::Document::Components::DataTypes::Uri)).to be_truthy
    end
  end
end
