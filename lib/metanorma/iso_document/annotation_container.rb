# frozen_string_literal: true

module Metanorma
  module IsoDocument
    # Container for review annotations. Uses map_all_content to preserve
    # mixed content including annotation elements with their p children.
    class AnnotationContainer < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element "annotation-container"
        map_all_content to: :content
      end
    end
  end
end
