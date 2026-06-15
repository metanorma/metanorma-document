# frozen_string_literal: true

module Metanorma
  module Mirror
    module Output
      module HtmlRenderers
        autoload :StructuralRenderers, "#{__dir__}/html_renderers/structural_renderers"
        autoload :SectionRenderers, "#{__dir__}/html_renderers/section_renderers"
        autoload :BlockRenderers, "#{__dir__}/html_renderers/block_renderers"
        autoload :ListRenderers, "#{__dir__}/html_renderers/list_renderers"
        autoload :TableRenderers, "#{__dir__}/html_renderers/table_renderers"
        autoload :InlineRenderer, "#{__dir__}/html_renderers/inline_renderer"
        autoload :MarkRenderers, "#{__dir__}/html_renderers/mark_renderers"

        MODULES = %i[
          StructuralRenderers
          SectionRenderers
          BlockRenderers
          ListRenderers
          TableRenderers
          InlineRenderer
          MarkRenderers
        ].freeze

        def self.register_all(renderer_class)
          MODULES.each { |mod_name| const_get(mod_name).register(renderer_class) }
        end
      end
    end
  end
end
