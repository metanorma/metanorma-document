# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Mathematical text formatted in MathML.
        # Captures the full MathML subtree as raw XML content.
        class MathmlNamespace < Lutaml::Xml::Namespace
          uri "http://www.w3.org/1998/Math/MathML"
          prefix_default "mathml"
        end

        class Mathml < Lutaml::Model::Serializable
          attribute :content, :string

          xml do
            element "math"
            namespace MathmlNamespace
            map_all_content to: :content
          end
        end
      end
    end
  end
end
