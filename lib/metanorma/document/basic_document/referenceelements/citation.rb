# frozen_string_literal: true

module Metanorma; module Document; module BasicDocument
  # Representation of a citation of a bibliographic item, typically within a document.
  class Citation < Core::Node
    include Core::Node::Custom

    register_element do
      # Date of the citation, typically date of publication. A combination of the date time elements
      # year, month and day should be specified.
      # Specification of month and day are optional.
      #
      # This date is not intended for disambiguation, since `bibitemid`
      # already identifies the source unambiguously; it is added for ease of processing, in case author-date
      # citations cannot straightforwardly extract the date from the bibliographic source.
      attribute :date, Iso8601DateTime

      # Describes the location of the cited information resource within
      # the subject of the bibliographic item.
      # Multiple ``bibLocality``s are interpreted as discontinuous references.
      #
      # NOTE: `bibLocality` and `bibLocalityStack` are mutually exclusive.
      nodes :bib_locality, Relaton::BibItemLocality

      # Describes the location of the cited information resource within
      # the subject of the bibliographic item in a multi-level manner.
      # For example, the hierarchical specification "Part IV, Chapter 3, Paragraphs 22-24"
      # is represented as a single `bibLocalityStack`, composed of those three localities
      # (as opposed to three `bibLocality` references, which would be treated as
      # three discontinuous references).
      # Multiple ``bibLocalityStack``s are themselves interpreted as discontinuous references.
      #
      # NOTE: `bibLocality` and `bibLocalityStack` are mutually exclusive.
      nodes :bib_locality_stack, Relaton::LocalityStack

      # Bibliographic item that the citation applies to.
      #
      # NOTE: `bibItem` is realised in serialisation as a crossreference to a complete
      # `bibItem` record elsewhere in a document.
      #
      # A single citation may span multiple bibliographic items.
      #
      # [example]
      # A contiguous or disjoint range of volumes can be represented with an
      # aggregatation of multiple bibliographic items.
      node :bib_item, BibliographicItem
    end
  end
end; end; end
