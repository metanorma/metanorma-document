# frozen_string_literal: true

RSpec.describe Metanorma::Document do
  it "has a version number" do
    expect(Metanorma::Document::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
