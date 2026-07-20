# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "M3D document XML round-trip" do
  it_behaves_like "xml round-trip", flavor_dir: "m3d",
                                    doc_class: Metanorma::M3dDocument::Root
end
