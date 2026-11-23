# frozen_string_literal: true

require_relative "rendered_display"

module Metanorma
  module Document
    module Components
      module Inline
        # Optional presentation metadata produced by a labelling processor.
        # This is a presentation vocabulary extension, never semantic content.
        # It deliberately has no dependency on the processor that computes it.
        class FmtLadlLabelData < Lutaml::Model::Serializable
          include RenderedDisplay

          attribute :local, :string
          attribute :global, :string
          attribute :value, :string
          attribute :direction, :string
          attribute :global_direction, :string
          attribute :labeller, :string

          xml do
            element "fmt-ladl-label-data"
            map_attribute "local", to: :local
            map_attribute "global", to: :global
            map_attribute "value", to: :value
            map_attribute "direction", to: :direction
            map_attribute "global-direction", to: :global_direction
            map_attribute "labeller", to: :labeller
          end
        end
      end
    end
  end
end
