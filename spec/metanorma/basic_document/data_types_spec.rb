# frozen_string_literal: true

RSpec.describe Metanorma::Document::Components::DataTypes do
  it "is defined" do
    defined?(described_class).should be_truthy
  end

  describe "classes" do
    it "autoloads FormattedString" do
      defined?(Metanorma::Document::Components::DataTypes::FormattedString).should be_truthy
    end

    it "autoloads Iso15924Code" do
      defined?(Metanorma::Document::Components::DataTypes::Iso15924Code).should be_truthy
    end

    it "autoloads Iso3166Code" do
      defined?(Metanorma::Document::Components::DataTypes::Iso3166Code).should be_truthy
    end

    it "autoloads Iso639Code" do
      defined?(Metanorma::Document::Components::DataTypes::Iso639Code).should be_truthy
    end

    it "autoloads Iso8601DateTime" do
      defined?(Metanorma::Document::Components::DataTypes::Iso8601DateTime).should be_truthy
    end

    it "autoloads LocalizedString" do
      defined?(Metanorma::Document::Components::DataTypes::LocalizedString).should be_truthy
    end

    it "autoloads StringFormat" do
      defined?(Metanorma::Document::Components::DataTypes::StringFormat).should be_truthy
    end

    it "autoloads Uri" do
      defined?(Metanorma::Document::Components::DataTypes::Uri).should be_truthy
    end
  end
end
