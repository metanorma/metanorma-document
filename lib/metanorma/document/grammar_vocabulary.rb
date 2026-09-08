# frozen_string_literal: true

module Metanorma
  module Document
    # The standoc-grammar element vocabulary this gem is accountable
    # for (#2): every element defined by standoc-models (standoc.rnc +
    # basicdoc.rnc, plus the standoc-presentation.rnc overlay) is
    # either mapped by a model class here, delegated to its owning
    # tree, or tracked as a gap. The grammar-coverage spec asserts the
    # classification; `rake grammar_coverage` diffs it against a
    # standoc-models checkout when the grammars change.
    module GrammarVocabulary
      ELEMENT_PATTERN = /element\s+([a-zA-Z0-9_.:-]+)\s*\{/

      # Regenerate the vocabulary from a standoc-models grammars/
      # directory: { semantic: [...], presentation: [...] }
      def self.scan(grammars_dir)
        semantic = ["#{grammars_dir}/standoc.rnc"]
          .concat(Dir["#{grammars_dir}/basicdoc-models/grammars/*.rnc"])
          .flat_map { |f| File.read(f, encoding: "utf-8").scan(ELEMENT_PATTERN).flatten }
          .uniq.sort
        presentation = File.read("#{grammars_dir}/standoc-presentation.rnc",
                                 encoding: "utf-8")
          .scan(ELEMENT_PATTERN).flatten.uniq.sort
        { semantic: semantic, presentation: presentation }
      end

      SEMANTIC_ELEMENTS = %w[
        abbreviation-type abstract acknowledgements add admitted admonition
        altsource amend annex annotation annotation-container appendix
        area asciimath attribute audio author autonumber
        bibdata bibitem bibliography body boilerplate bookmark
        br callout callout-annotation classification clause col
        colgroup colophon columnbreak concept coords copyright-statement
        date dd definition definitions del deprecates
        description display-text dl document domain dt
        em eref erefstack errormsg example executivesummary
        expression feedback-statement field-of-application figure floating-title fn
        foreword form formula gender grammar grammar-value
        graphical-symbol hr image imagemap index index-xref
        indexsect input introduction isAdjective isAdverb isNoun
        isParticiple isPreposition isVerb key keyword label
        latexmath legal-statement letter-symbol li license-statement link
        location metanorma metanorma-extension modification name newcontent
        non-verbal-representation note number ol option origin
        p pagebreak passthrough pre preface preferred
        primary pronunciation quote radius references refterm
        related renderterm review ruby ruby-annotation ruby-pronunciation
        secondary section sections select smallcap source
        sourcecode span stem strike strong sub
        subject sup svg svgmap table tag
        target tbody td term termdocsource termexample
        termnote termref terms tertiary textarea tfoot
        th thead title toc tr tt
        ul underline usage-info value variable-ref variant-title
        verbal-definition video xref
      ].freeze

      PRESENTATION_ELEMENTS = %w[
        annotation-container attribution author bibitem biblio-tag dd
        emf eref fmt-admitted fmt-annotation-body fmt-annotation-end fmt-annotation-start
        fmt-concept fmt-date-inline fmt-definition fmt-deprecates fmt-eref fmt-figure
        fmt-fn-body fmt-fn-label fmt-footnote-container fmt-identifier fmt-link fmt-name
        fmt-ol fmt-origin fmt-preferred fmt-provision fmt-related fmt-source
        fmt-sourcecode fmt-stem fmt-termsource fmt-title fmt-ul fmt-xref-label
        image li localized-string localized-strings metanorma-extension name
        p passthrough rb rt ruby semx
        source source-highlighter-css sourcelocalityStack svg tab term
        termexample termnote title toc variant-title
      ].freeze

      # Elements owned by other model trees — mapped there, not here:
      #   standoc  : the sections/terms/metadata tree (metanorma-standoc)
      #   relaton  : the bibliographic models (relaton)
      #   reqt     : the requirements vocabulary (requirements models)
      #   basicdoc_only : defined by basicdoc, referenced by no standoc
      #                   content model — dead vocabulary until adopted
      DELEGATED = {
        standoc: %w[
          abbreviation-type acknowledgements amend annex annotation-container
          appendix autonumber bibliography boilerplate clause colophon
          copyright-statement executivesummary expression
          feedback-statement field-of-application floating-title foreword form
          gender graphical-symbol grammar grammar-value indexsect introduction
          isAdjective isAdverb isNoun isParticiple isPreposition isVerb label
          legal-statement letter-symbol license-statement metanorma-extension
          newcontent non-verbal-representation option preface pronunciation
          related sections select source-highlighter-css term
          termdocsource termexample termnote terms textarea toc usage-info
          fmt-deprecates fmt-related
        ],
        relaton: %w[altsource],
        reqt: %w[attribute],
        # basicdoc's own parallel document structure (basicdoc root
        # `document`, generic nested `section`) — standoc content
        # models reference neither; the collection manifest root is the
        # metanorma gem's own model.
        basicdoc_only: %w[document section variable-ref],
      }.freeze

      # Presentation-overlay elements with no model yet. EMPTY since
      # the fmt-twins wave (#63): every element this gem owns —
      # semantic and rendered — parses. sourcelocalityStack parses its
      # text; its child pattern is a dangling grammar reference
      # (standoc-models issue), extended when the grammar defines it.
      KNOWN_GAPS = [].freeze
    end
  end
end
