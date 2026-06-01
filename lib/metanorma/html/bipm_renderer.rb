# frozen_string_literal: true

module Metanorma
  module Html
    class BipmRenderer < IsoRenderer
      register_render Metanorma::BipmDocument::Root, :render_document
      register_render Metanorma::StandardDocument::Sections::Preface,
                      :render_preface
      register_render Metanorma::StandardDocument::Sections::ClauseSection,
                      :render_clause
      register_render Metanorma::StandardDocument::Sections::AnnexSection,
                      :render_annex
      register_render Metanorma::StandardDocument::Sections::ContentSection,
                      :render_clause
      register_render Metanorma::StandardDocument::Sections::TermsSection,
                      :render_terms_section
      register_render Metanorma::StandardDocument::Sections::BibliographySection,
                      :render_clause
      register_render Metanorma::StandardDocument::Sections::DefinitionSection,
                      :render_clause
    end
  end
end
