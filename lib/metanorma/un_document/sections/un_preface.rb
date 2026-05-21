# frozen_string_literal: true

module Metanorma
  module UnDocument
    module Sections
      # UN preface with only abstract, foreword, introduction.
      # Corresponds to un.rnc:
      #   preface = element preface { abstract?, foreword?, introduction? }
      class UnPreface < Metanorma::StandardDocument::Sections::Preface
        xml do
          element "preface"
          ordered

          map_element "abstract",      to: :abstract
          map_element "foreword",      to: :foreword
          map_element "introduction",  to: :introduction

          Metanorma::StandardDocument::SectionXmlMapping.apply_preface_attributes(self)
        end
      end
    end
  end
end
