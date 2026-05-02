# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "OIML document XML round-trip" do
  it_behaves_like "xml round-trip", flavor_dir: "oiml/r060"
end
