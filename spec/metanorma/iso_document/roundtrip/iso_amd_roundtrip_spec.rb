# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "ISO AMD document XML round-trip" do
  it_behaves_like "xml round-trip", flavor_dir: "iso/amd", full: false
end
