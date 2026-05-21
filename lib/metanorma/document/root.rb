# frozen_string_literal: true

module Metanorma
  module Document
    # Base root class for all Metanorma document flavors.
    # All document types inherit from this.
    class Root < Lutaml::Model::Serializable
      attribute :autonum, :string
      attribute :fmt_xref_label, :string
    end
  end
end
