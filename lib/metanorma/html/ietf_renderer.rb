# frozen_string_literal: true

module Metanorma
  module Html
    class IetfRenderer < IsoRenderer
      register_render Metanorma::IetfDocument::Root, :render_document
    end
  end
end
