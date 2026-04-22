# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Tables
        # Table cell for <td> and <th> elements with inline content.
        class TextTableCell < TableCell
          xml do
            element "td"
            mixed_content
          end
        end
      end
    end
  end
end
