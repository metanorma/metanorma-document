# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Document
    # Base root class for all Metanorma document flavors.
    # All document types (StandardDocument, IsoDocument) inherit from this.
    class Root < Lutaml::Model::Serializable
      attribute :autonum, :string
      attribute :fmt_xref_label, :string
    end
  end
end
