# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module MultiParagraph
        # Subclass of admonition determining how it is to be rendered.
        class AdmonitionType < Lutaml::Model::Serializable
          attribute :value, :string

          xml do
            element "admonition-type"
            map_content to: :value

            def self.values
              %w[warning note tip important caution statement]
            end
          end
        end
      end
    end
  end
end
