# frozen_string_literal: true

module Metanorma
  module Mirror
    module Model
      class SoftBreak < Lutaml::Model::Serializable
        attribute :type, :string, default: -> { "soft_break" }

        key_value do
          map "type", to: :type, render_default: true
        end

        # rewriter contract: a soft break carries no attrs or content
        def attrs
          {}
        end

        def content
          []
        end

        def text_content
          ""
        end

        def accept_rewriter(rewriter)
          rewriter.rewrite_soft_break(self)
        end
      end
    end
  end
end
