# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "IETF document XML round-trip" do
  it_behaves_like "xml round-trip", flavor_dir: "ietf",
                                    doc_class: Metanorma::IetfDocument::Root
end
