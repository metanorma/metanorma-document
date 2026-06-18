# frozen_string_literal: true

module Metanorma
  module Mirror
    # Extracts metadata (title, etc.) from a parsed Metanorma document's
    # bibdata. This is a standalone service that the pipeline and other
    # consumers can use without depending on the Handlers layer.
    module Metadata
      # Returns the first title string from a bibdata object, or nil.
      # The bibdata must respond to `title` and return a String, an Array
      # of Strings, or an Array of Lutaml::Model::Serializables with
      # `content`.
      def self.title_from_bibdata(bibdata)
        return nil unless bibdata

        title = bibdata.title
        return nil unless title

        case title
        when String then title
        when Array
          first = title.first
          return nil unless first

          if first.is_a?(String)
            first
          elsif first.is_a?(Lutaml::Model::Serializable)
            Array(first.content).join
          else
            first.to_s
          end
        else title.to_s
        end
      end
    end
  end
end
