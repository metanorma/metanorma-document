# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # Hierarchical arrangement of bibliographic localities, to designate a single span of text in a
  # bibliographic item.
  class LocalityStack < Core::Node
    include Core::Node::Custom

    register_element do
      # Component bibliographic localities which group together to designate a single span of text.
      # Earlier localities are assumed to include later localities, and be of different types;
      # e.g. "Chapter 7, paragraph 9–11".
      nodes :bib_locality, BibItemLocality
    end
  end
end; end; end
