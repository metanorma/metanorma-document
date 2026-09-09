# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Lists
        # The rendered list forms fmt-ul/fmt-ol: the presentation
        # rendering of a list that deviates from a sequence of list
        # items (e.g. rendered as a table). Present to the exclusion
        # of any other child of the semantic list. Declared as a
        # module and re-applied per class (lutaml inherits neither the
        # attribute registry nor xml mappings).
        module FmtListContract
          module_function

          def declare_attributes(base)
            base.attribute :id, :string
            base.attribute :anchor, :string
            base.attribute :semx_id, :string
            base.attribute :name,
                           Metanorma::Document::Components::Inline::NameWithIdElement
            base.attribute :table,
                           "Metanorma::Document::Components::Tables::TableBlock",
                           collection: true
            base.attribute :note,
                           Metanorma::Document::Components::Blocks::NoteBlock,
                           collection: true
            base.attribute :text, :string, collection: true
            base.attribute :semx,
                           "Metanorma::Document::Components::Inline::SemxElement",
                           collection: true
          end

          def apply_mapping(mapping)
            mapping.mixed_content
            mapping.map_attribute "id", to: :id
            mapping.map_attribute "anchor", to: :anchor
            mapping.map_attribute "semx-id", to: :semx_id
            mapping.map_element "name", to: :name
            mapping.map_element "table", to: :table
            mapping.map_element "note", to: :note
            mapping.map_content to: :text
            mapping.map_element "semx", to: :semx
          end
        end

        # Rendered counterpart of `<ul>`.
        class FmtUlElement < Lutaml::Model::Serializable
          include Metanorma::Document::Components::Inline::RenderedDisplay

          FmtListContract.declare_attributes(self)

          xml do
            element "fmt-ul"
            FmtListContract.apply_mapping(self)
          end
        end

        # Rendered counterpart of `<ol>`.
        class FmtOlElement < Lutaml::Model::Serializable
          include Metanorma::Document::Components::Inline::RenderedDisplay

          FmtListContract.declare_attributes(self)

          xml do
            element "fmt-ol"
            FmtListContract.apply_mapping(self)
          end
        end
      end
    end
  end
end
