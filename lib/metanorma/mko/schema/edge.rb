# frozen_string_literal: true

module Metanorma
  module Mko
    module Schema
      # One graph edge between knowledge objects (or an external key).
      # Kinds: part_of, cites, defines, tested_by, class_of, amends,
      # variant_of, supersedes.
      class Edge < Lutaml::Model::Serializable
        attribute :from, :string
        attribute :to, :string
        attribute :kind, :string

        json do
          map "from", to: :from
          map "to", to: :to
          map "kind", to: :kind
        end
      end
    end
  end
end
