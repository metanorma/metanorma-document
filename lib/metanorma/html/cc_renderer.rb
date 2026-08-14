# frozen_string_literal: true

module Metanorma
  module Html
    class CcRenderer < IsoRenderer
      register_render "Metanorma::Cc::Document::Root", :render_document
    end
  end
end
