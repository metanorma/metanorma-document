# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      module Inline
        autoload :NameWithIdElement,
                 "metanorma/document/components/inline/name_with_id_element"
        autoload :SmallCapElement,
                 "metanorma/document/components/inline/small_cap_element"
        autoload :CommaElement,
                 "metanorma/document/components/inline/comma_element"
        autoload :EnumCommaElement,
                 "metanorma/document/components/inline/enum_comma_element"
        autoload :XrefElement,
                 "metanorma/document/components/inline/xref_element"
        autoload :ErefElement,
                 "metanorma/document/components/inline/eref_element"
        autoload :LinkElement,
                 "metanorma/document/components/inline/link_element"
        autoload :BrElement, "metanorma/document/components/inline/br_element"
        autoload :TabElement, "metanorma/document/components/inline/tab_element"
        autoload :AsciimathElement,
                 "metanorma/document/components/inline/asciimath_element"
        autoload :MathElement,
                 "metanorma/document/components/inline/math_element"
        autoload :SupElement, "metanorma/document/components/inline/sup_element"
        autoload :SubElement, "metanorma/document/components/inline/sub_element"
        autoload :TtElement, "metanorma/document/components/inline/tt_element"
        autoload :StrongRawElement,
                 "metanorma/document/components/inline/strong_raw_element"
        autoload :EmRawElement,
                 "metanorma/document/components/inline/em_raw_element"
        autoload :StemInlineElement,
                 "metanorma/document/components/inline/stem_inline_element"
        autoload :ConceptElement,
                 "metanorma/document/components/inline/concept_element"
        autoload :FnElement, "metanorma/document/components/inline/fn_element"
        autoload :SemxChildElement,
                 "metanorma/document/components/inline/semx_child_element"
        autoload :SemxElement,
                 "metanorma/document/components/inline/semx_element"
        autoload :SpanElement,
                 "metanorma/document/components/inline/span_element"
        autoload :FmtStemElement,
                 "metanorma/document/components/inline/fmt_stem_element"
        autoload :FmtFnLabelElement,
                 "metanorma/document/components/inline/fmt_fn_label_element"
        autoload :FmtConceptElement,
                 "metanorma/document/components/inline/fmt_concept_element"
        autoload :FmtXrefElement,
                 "metanorma/document/components/inline/fmt_xref_element"
        autoload :FmtNameElement,
                 "metanorma/document/components/inline/fmt_name_element"
        autoload :FmtTitleElement,
                 "metanorma/document/components/inline/fmt_title_element"
        autoload :FmtXrefLabelElement,
                 "metanorma/document/components/inline/fmt_xref_label_element"
        autoload :FmtFnBodyElement,
                 "metanorma/document/components/inline/fmt_fn_body_element"
        autoload :FmtPreferredElement,
                 "metanorma/document/components/inline/fmt_preferred_element"
        autoload :FmtDefinitionElement,
                 "metanorma/document/components/inline/fmt_definition_element"
        autoload :FmtTermsourceElement,
                 "metanorma/document/components/inline/fmt_termsource_element"
        autoload :FmtAdmittedElement,
                 "metanorma/document/components/inline/fmt_admitted_element"
        autoload :FmtIdentifierElement,
                 "metanorma/document/components/inline/fmt_identifier_element"
        autoload :BiblioTagElement,
                 "metanorma/document/components/inline/biblio_tag_element"
        autoload :LocalizedStringElement,
                 "metanorma/document/components/inline/localized_string_element"
        autoload :LocalizedStringsElement,
                 "metanorma/document/components/inline/localized_strings_element"
        autoload :FmtFootnoteContainerElement,
                 "metanorma/document/components/inline/fmt_footnote_container_element"
        autoload :FmtAnnotationBodyElement,
                 "metanorma/document/components/inline/fmt_annotation_body_element"
        autoload :FmtAnnotationEndElement,
                 "metanorma/document/components/inline/fmt_annotation_end_element"
        autoload :FmtAnnotationStartElement,
                 "metanorma/document/components/inline/fmt_annotation_start_element"
        autoload :VariantTitleElement,
                 "metanorma/document/components/inline/variant_title_element"
        autoload :FmtSourcecodeElement,
                 "metanorma/document/components/inline/fmt_sourcecode_element"
        autoload :AttributionElement,
                 "metanorma/document/components/inline/attribution_element"
        autoload :TitleWithAnnotationElement,
                 "metanorma/document/components/inline/title_with_annotation_element"
        autoload :DisplayTextElement,
                 "metanorma/document/components/inline/display_text_element"
      end
    end
  end
end
