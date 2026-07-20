# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "Ribose document XML round-trip" do
  it_behaves_like "xml round-trip", flavor_dir: "ribose",
                                    doc_class: Metanorma::RiboseDocument::Root
end
