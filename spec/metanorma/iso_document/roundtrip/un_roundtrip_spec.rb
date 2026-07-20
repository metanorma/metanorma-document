# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "UN document XML round-trip" do
  it_behaves_like "xml round-trip", flavor_dir: "un",
                                    doc_class: Metanorma::UnDocument::Root
end
