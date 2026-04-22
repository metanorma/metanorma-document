# frozen_string_literal: true

module Metanorma
  module Document
    module Relaton
      # A title of a bibliographic item, associated with a type of title.
      class TypedTitleString < Lutaml::Model::Serializable
        attribute :type, :string
        attribute :format, :string
        attribute :language, :string
        attribute :script, :string
        attribute :content, :string, collection: true
        attribute :em, Metanorma::Document::Components::Inline::EmRawElement,
                  collection: true
        attribute :strong, Metanorma::Document::Components::Inline::StrongRawElement,
                  collection: true
        attribute :sub, Metanorma::Document::Components::Inline::SubElement,
                  collection: true
        attribute :sup, Metanorma::Document::Components::Inline::SupElement,
                  collection: true
        attribute :tt, Metanorma::Document::Components::Inline::TtElement,
                  collection: true
        attribute :fn, Metanorma::Document::Components::Inline::FnElement,
                  collection: true
        attribute :stem, Metanorma::Document::Components::Inline::StemInlineElement,
                  collection: true
        attribute :variant, Metanorma::Document::Components::DataTypes::LocalizedString,
                  collection: true

        xml do
          element "title"
          mixed_content
          map_attribute "type", to: :type
          map_attribute "format", to: :format
          map_attribute "language", to: :language
          map_attribute "script", to: :script
          map_content to: :content
          map_element "em", to: :em
          map_element "strong", to: :strong
          map_element "sub", to: :sub
          map_element "sup", to: :sup
          map_element "tt", to: :tt
          map_element "fn", to: :fn
          map_element "stem", to: :stem
          map_element "variant", to: :variant
        end
      end
    end
  end
end
