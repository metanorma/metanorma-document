# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class FigureListEntryDrop < Liquid::Drop
        def initialize(entry)
          @entry = entry
        end

        def id = @entry[:id]
        def text = @entry[:text]
      end
    end
  end
end
