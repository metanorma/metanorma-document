# frozen_string_literal: true

module Metanorma
  module Html
    class ItuRenderer < IsoRenderer
      register_render Metanorma::ItuDocument::Root, :render_document
    end
  end
end
