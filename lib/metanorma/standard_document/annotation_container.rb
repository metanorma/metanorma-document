# frozen_string_literal: true

module Metanorma
  module StandardDocument
    class AnnotationContainer < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element "annotation-container"
        map_all_content to: :content
      end
    end
  end
end
