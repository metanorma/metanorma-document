# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        # A stack of source localities — the rendered form of the
        # localities a quote source cites (mirrors localityStack for
        # sources). The overlay references a `sourcelocality` child
        # pattern that no grammar defines (standoc-models dangling
        # reference); text parses today, the child maps once the
        # grammar defines it.
        class SourcelocalityStackElement < Lutaml::Model::Serializable
          include RenderedDisplay

          attribute :text, :string, collection: true

          xml do
            element "sourcelocalityStack"
            mixed_content
            map_content to: :text
          end
        end
      end
    end
  end
end
