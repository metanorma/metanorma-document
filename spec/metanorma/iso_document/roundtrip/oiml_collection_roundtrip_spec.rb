# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "OIML Collection XML round-trip" do
  it_behaves_like "collection round-trip", flavor_dir: "oiml/r060"
end
