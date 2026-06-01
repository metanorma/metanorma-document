# frozen_string_literal: true

module Metanorma
  module Html
    class OimlRenderer < IsoRenderer
      register_render Metanorma::OimlDocument::Root, :render_document

      DOCTYPE_ID_PATTERN = /\b([RGBDEVS])\s*\d/

      def extract_doctype(bibdata)
        oiml_doctype_from_doc_id(bibdata) || super
      end

      def extract_stage(bibdata)
        oiml_doctype_from_doc_id(bibdata) || super
      end

      private

      def oiml_doctype_from_doc_id(bibdata)
        labels = theme.doctype_labels
        return nil if labels.empty?

        doc_id = formatted_doc_id(bibdata).to_s
        return nil if doc_id.empty?

        if (match = doc_id.match(DOCTYPE_ID_PATTERN))
          labels[match[1]]
        end
      end
    end
  end
end
