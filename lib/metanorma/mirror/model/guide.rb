# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Guide < Lutaml::Model::Serializable
        attribute :content, [Container, :string]
        attribute :meta, :hash, default: -> { {} }
        attribute :title, :string

        key_value do
          map "content", to: :content
          map "meta", to: :meta, render_empty: false
          map "title", to: :title, render_nil: false
        end

        # the parsed source document rides along for output formats; it
        # is deliberately outside the serialization contract
        attr_accessor :document

        def initialize(content: nil, meta: {}, title: nil, document: nil,
                       **)
          super(content: content, meta: meta, title: title, **)
          self.document = document
        end
      end
    end
  end
end
