# frozen_string_literal: true

require "spec_helper"
require "pathname"

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

DELEGATED = {
  standoc: %w[
    abbreviation-type acknowledgements amend annex annotation-container
    appendix autonumber bibliography boilerplate clause colophon
    copyright-statement document executivesummary expression
    feedback-statement field-of-application floating-title foreword form
    gender graphical-symbol grammar grammar-value indexsect introduction
    isAdjective isAdverb isNoun isParticiple isPreposition isVerb label
    legal-statement letter-symbol license-statement metanorma-extension
    newcontent non-verbal-representation option preface pronunciation
    related section sections select source-highlighter-css term
    termdocsource termexample termnote terms textarea toc usage-info
    fmt-deprecates fmt-related
  ],
  relaton: %w[altsource],
  reqt: %w[attribute],
  metanorma: %w[],
  # Defined by basicdoc but referenced by no standoc content model:
  # dead vocabulary until standoc adopts it.
  basicdoc_only: %w[variable-ref],
}.freeze

KNOWN_GAPS = %w[
  emf fmt-date-inline fmt-eref fmt-figure fmt-ol fmt-origin
  fmt-source fmt-ul sourcelocalityStack
].freeze

# metanorma-document#2 — the element-coverage enumeration.
#
# Every element defined by the standoc grammars (standoc-models:
# standoc.rnc + basicdoc.rnc, and the standoc-presentation.rnc
# overlay) must be accounted for exactly once: either mapped by a
# model class in this gem, or explicitly DELEGATED to the tree that
# owns it, or tracked as a KNOWN GAP of this gem. A new grammar
# element that is none of these fails this spec — the enumeration is
# the gate that forces a mapping decision.
#
# Refresh procedure (when the grammars change): regenerate the three
# lists below from a standoc-models checkout:
#
#   core    = standoc.rnc + basicdoc-models/grammars/*.rnc element names
#   overlay = standoc-presentation.rnc element names
#   mapped  = scan this gem's lib for `element "x"` / `map_element "x"`
#
# and re-classify the difference.
LIB_GLOB = Pathname(__dir__).join("../../../lib/**/*.rb").freeze

RSpec.describe "standoc grammar element coverage" do
  def mapped_element_names
    Dir[LIB_GLOB].flat_map do |f|
      File.read(f, encoding: "utf-8")
        .scan(/(?:map_element|element)\s+"([a-zA-Z0-9_.:-]+)"/)
        .flatten
    end.uniq
  end

  # Elements defined by the semantic grammars (standoc.rnc +
  # basicdoc.rnc), regenerated from standoc-models.

  # Elements defined by the presentation overlay
  # (standoc-presentation.rnc), regenerated from standoc-models.

  # Elements owned by other model trees — mapped there, not here.
  #   standoc  : the sections/terms/metadata tree (metanorma-standoc)
  #   relaton  : the bibliographic models (relaton)
  #   reqt     : the requirements vocabulary (requirements models)
  #   metanorma: the collection manifest (metanorma gem)

  # Presentation-overlay elements with NO model yet, tracked for this
  # gem (the rendered twins of elements this gem owns, plus the
  # presentation-only image and locality forms). Each needs a model
  # with RenderedDisplay wired beside its semantic twin.

  it "accounts for every semantic grammar element exactly once" do
    mapped = mapped_element_names
    accounted = (mapped + DELEGATED.values.flatten + KNOWN_GAPS)

    overlaps = accounted.tally.select { |_, n| n > 1 }.keys
    expect(overlaps).to be_empty,
                        "elements accounted for more than once: #{overlaps.join(', ')}"

    missing = (SEMANTIC_ELEMENTS + PRESENTATION_ELEMENTS) - accounted
    expect(missing).to be_empty,
                       "grammar elements with no mapping and no classification: " \
                       "#{missing.join(', ')}"
  end

  it "classifies delegated and gap elements that exist in the grammar" do
    listed = DELEGATED.values.flatten + KNOWN_GAPS
    unknown = listed - (SEMANTIC_ELEMENTS + PRESENTATION_ELEMENTS)
    expect(unknown).to be_empty,
                       "classification lists name elements the grammar does " \
                       "not define (stale?): #{unknown.join(', ')}"
  end

  it "maps the ruby/svgmap/imagemap coverage added for #2" do
    mapped = mapped_element_names
    %w[ruby ruby-pronunciation ruby-annotation rb columnbreak svgmap
       imagemap area coords radius target].each do |el|
      expect(mapped).to include(el), "#{el} must stay mapped in this gem"
    end
  end
end
