# frozen_string_literal: true

module Metanorma
  module Html
    class RiboseRenderer < IsoRenderer
      register_render "Metanorma::Ribose::Document::Root", :render_document
    end
  end
end
