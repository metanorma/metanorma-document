# frozen_string_literal: true

module Metanorma
  module Html
    module Drops
      autoload :FootnoteDrop, "metanorma/html/drops/footnote_drop"
      autoload :BlockElementDrop, "metanorma/html/drops/block_element_drop"
      autoload :NoteDrop, "metanorma/html/drops/note_drop"
      autoload :AdmonitionDrop, "metanorma/html/drops/admonition_drop"
      autoload :ExampleDrop, "metanorma/html/drops/example_drop"
      autoload :SourcecodeDrop, "metanorma/html/drops/sourcecode_drop"
      autoload :FormulaDrop, "metanorma/html/drops/formula_drop"
      autoload :FigureDrop, "metanorma/html/drops/figure_drop"
      autoload :TocEntryDrop, "metanorma/html/drops/toc_entry_drop"
      autoload :FigureListEntryDrop, "metanorma/html/drops/figure_list_entry_drop"
    end
  end
end
