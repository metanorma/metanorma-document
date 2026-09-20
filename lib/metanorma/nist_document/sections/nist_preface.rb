# frozen_string_literal: true

module Metanorma
  module NistDocument
    module Sections
      # NIST preface with errata and executivesummary support.
      # Corresponds to nist.rnc:
      #   preface = element preface {
      #     abstract?, foreword?,
      #     (clause | errata_clause | acknowledgements)*,
      #     content*,
      #     executivesummary?
      #   }
      class NistPreface < Metanorma::StandardDocument::Sections::Preface
        attribute :errata_clause, ErrataClause, collection: true

        xml do
          element "preface"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_preface_elements(self)
          map_element "clause",            to: :content
          map_element "errata_clause",     to: :errata_clause

          Metanorma::StandardDocument::SectionXmlMapping.apply_preface_attributes(self)
        end
      end
    end
  end
end
