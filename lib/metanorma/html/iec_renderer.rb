# frozen_string_literal: true

module Metanorma
  module Html
    class IecRenderer < IsoRenderer
      register_render "Metanorma::Iec::Document::Root", :render_document
    end
  end
end
