# frozen_string_literal: true

module Metanorma
  module Html
    class IhoRenderer < IsoRenderer
      register_render Metanorma::IhoDocument::Root, :render_document
    end
  end
end
