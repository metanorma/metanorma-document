# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Blocks
        class RequirementSpecification < RequirementDescription
          xml do
            element "specification"
            map_element "p", to: :p
            map_element "ul", to: :ul
            map_element "ol", to: :ol
            map_element "sourcecode", to: :sourcecode
            map_element "table", to: :table
            map_element "example", to: :example
            map_element "note", to: :note
            map_element "figure", to: :figure
          end
        end
      end
    end
  end
end
