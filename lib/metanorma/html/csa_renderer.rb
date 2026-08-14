# frozen_string_literal: true

module Metanorma
  module Html
    class CsaRenderer < IsoRenderer
      register_render "Metanorma::Csa::Document::Root", :render_document
    end
  end
end
