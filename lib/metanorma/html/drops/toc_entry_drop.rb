# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      class TocEntryDrop < Liquid::Drop
        def initialize(entry)
          @entry = entry
        end

        def id = @entry[:id]
        def text = @entry[:text]
        def level = @entry[:level]
      end
    end
  end
end
