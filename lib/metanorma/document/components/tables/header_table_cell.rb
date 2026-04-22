# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        # Table cell for <th> elements.
        class HeaderTableCell < TableCell
          xml do
            element "th"
            mixed_content
          end
        end
      end
    end
  end
end
