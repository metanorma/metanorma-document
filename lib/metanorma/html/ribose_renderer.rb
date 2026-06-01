# frozen_string_literal: true

module Metanorma
  module Html
    class RiboseRenderer < IsoRenderer
      register_render Metanorma::RiboseDocument::Root, :render_document
    end
  end
end
