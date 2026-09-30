# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      # The semantic vocabulary namespace (semantic__* elements under
      # metanorma-extension/metanorma/source): the machine-readable
      # layer flavors embed alongside the presentation tree. Element
      # names are dynamic per flavor and document, so ONE recursive
      # model with a catch-all element mapping serves the whole
      # namespace (lutaml-model#903/#905); element_order preserves the
      # mixed-content sequence and each child's original tag name for
      # ordered rendering.
      module Semantic
        class Node < Lutaml::Model::Serializable
          attribute :children,
                    "Metanorma::Document::Components::Semantic::Node",
                    collection: true

          # Attributes actually consumed by rendering; the rest of the
          # vocabulary's attribute surface drops at parse. sem_-prefixed
          # names avoid collisions with the children attribute.
          XML_ATTRIBUTES = {
            "id" => :id, "target" => :sem_target, "citeas" => :citeas,
            "bibitemid" => :bibitemid, "type" => :type_attr,
            "language" => :sem_language, "script" => :sem_script,
            "format" => :format, "alt" => :alt, "style" => :sem_style,
            "display" => :display, "scope" => :scope, "role" => :sem_role,
            "label" => :label, "number" => :sem_number, "value" => :sem_value,
            "url" => :url, "href" => :href, "from" => :sem_from,
            "prefix" => :prefix, "hidden" => :hidden, "obligation" => :obligation,
          }.freeze

          XML_ATTRIBUTES.each_value { |attr| attribute attr, :string }

          xml do
            map_any_element to: :children
            XML_ATTRIBUTES.each do |xml_name, attr|
              map_attribute xml_name, to: attr
            end
          end
        end
      end
    end
  end
end
