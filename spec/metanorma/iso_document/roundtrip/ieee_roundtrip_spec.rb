# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "IEEE document XML round-trip" do
  it_behaves_like "xml round-trip", flavor_dir: "ieee",
                                    doc_class: Metanorma::IeeeDocument::Root
end
