# frozen_string_literal: true

module Metanorma
  module Html
    class IetfRenderer < IsoRenderer
      register_render "Metanorma::Ietf::Document::Root", :render_document
    end
  end
end
