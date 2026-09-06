# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class Text < Lutaml::Model::Serializable
        attribute :type, :string, default: -> { "text" }
        attribute :text, :string, default: -> { "" }
        attribute :marks, Mark, collection: true, default: -> { [] }

        key_value do
          map "type", to: :type, render_default: true
          map "text", to: :text, render_default: true, render_empty: true
          map "marks", to: :marks, render_empty: false
        end

        def text_content
          text
        end

        def accept_rewriter(rewriter)
          rewriter.rewrite_text(self)
        end
      end
    end
  end
end
