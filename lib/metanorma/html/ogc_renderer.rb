# frozen_string_literal: true

module Metanorma
  module Html
    class OgcRenderer < IsoRenderer
      register_render "Metanorma::Ogc::Document::Root", :render_document
      register_render "Metanorma::Standoc::Document::Sections::Preface",
                      :render_preface
      register_render "Metanorma::Standoc::Document::Sections::ClauseSection",
                      :render_clause
      register_render "Metanorma::Standoc::Document::Sections::AnnexSection",
                      :render_annex
      register_render "Metanorma::Standoc::Document::Sections::ContentSection",
                      :render_clause
      register_render "Metanorma::Standoc::Document::Sections::TermsSection",
                      :render_terms_section
      register_render "Metanorma::Standoc::Document::Sections::BibliographySection",
                      :render_clause
      register_render "Metanorma::Standoc::Document::Sections::DefinitionSection",
                      :render_clause
    end
  end
end
