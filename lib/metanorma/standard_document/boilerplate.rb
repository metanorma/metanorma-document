# frozen_string_literal: true

module Metanorma
  module StandardDocument
    class Boilerplate < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element "boilerplate"
        map_all_content to: :content
      end
    end
  end
end
