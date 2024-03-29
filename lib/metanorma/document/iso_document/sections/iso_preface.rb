# frozen_string_literal: true

module Metanorma; module Document; module IsoDocument
  # Prefatory clauses appearing in an ISO/IEC document.
  class IsoPreface < Core::Node
    include Core::Node::Custom

    register_element do
      # Abstract.
      node :abstract, BasicDocument::BasicSection

      # Foreword.
      node :foreword, BasicDocument::BasicSection

      # Introduction.
      node :introduction, StandardDocument::ClauseSection
    end
  end
end; end; end
