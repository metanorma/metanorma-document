# frozen_string_literal: true

module Metanorma
  module Html
    class CcRenderer < IsoRenderer
      register_render Metanorma::CcDocument::Root, :render_document
    end
  end
end
