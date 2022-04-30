# frozen_string_literal: true

module Metanorma; module Document; module Relaton
  # The publication or preparation status of a document.
  class DocumentStatus < Core::Node
    include Core::Node::Custom

    register_element do
      # The stage of the document status, e.g. "Published", "Unpublished", "Committee Draft", "Preprint".
      node :stage, BasicDocument::LocalizedString

      # A canonical abbreviation of the document status.
      node :stage_abbreviation, BasicDocument::LocalizedString

      # The substage of the document status. These are used particularly in Standards Defining
      # Organizations.
      node :substage, BasicDocument::LocalizedString

      # A canonical abbreviation of the document substage.
      node :substage_abbreviation, BasicDocument::LocalizedString

      # The iteration of the given status that the document is currently in (e.g. "3" for a third draft).
      node :iteration, BasicDocument::LocalizedString
    end
  end
end; end; end
