# frozen_string_literal: true

require_relative "../../../spec_helper"

require "metanorma/csa_document"

RSpec.describe "CSA document XML round-trip" do
  it_behaves_like "xml round-trip", flavor_dir: "csa",
                                    doc_class: Metanorma::CsaDocument::Root
end
