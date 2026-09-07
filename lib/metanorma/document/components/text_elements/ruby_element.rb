# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module TextElements
        # Text with Ruby annotations in East Asian languages.
        # Corresponds to HTML `ruby`.
        #
        # Semantic form: a leading pronunciation or semantic
        # annotation, then the annotated text, which may itself nest
        # further ruby.
        #
        # Presentation form: `rb` (the base text) and `rt` (the
        # rendered annotation).
        class RubyElement < Lutaml::Model::Serializable
          attribute :pronunciation,
                    "Metanorma::Document::Components::TextElements::RubyPronunciationElement"
          attribute :annotation,
                    "Metanorma::Document::Components::TextElements::RubyAnnotationElement"
          attribute :ruby_base,
                    "Metanorma::Document::Components::TextElements::RbElement"
          attribute :ruby_text, :string, collection: true
          attribute :ruby,
                    "Metanorma::Document::Components::TextElements::RubyElement",
                    collection: true
          attribute :text, :string, collection: true

          xml do
            element "ruby"
            mixed_content
            map_element "ruby-pronunciation", to: :pronunciation
            map_element "ruby-annotation", to: :annotation
            map_element "rb", to: :ruby_base
            map_element "rt", to: :ruby_text
            map_element "ruby", to: :ruby
            map_content to: :text
          end
        end

        # The base text of a presentation-form ruby annotation.
        class RbElement < Lutaml::Model::Serializable
          attribute :text, :string, collection: true
          attribute :ruby,
                    "Metanorma::Document::Components::TextElements::RubyElement",
                    collection: true

          xml do
            element "rb"
            mixed_content
            map_content to: :text
            map_element "ruby", to: :ruby
          end
        end
      end
    end
  end
end
