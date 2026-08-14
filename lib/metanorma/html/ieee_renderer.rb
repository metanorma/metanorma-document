# frozen_string_literal: true

module Metanorma
  module Html
    class IeeeRenderer < IsoRenderer
      register_render "Metanorma::Ieee::Document::Root", :render_document
    end
  end
end
