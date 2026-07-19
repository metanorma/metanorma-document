# frozen_string_literal: true

require "cgi"

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        class SourcecodeBody < Lutaml::Model::Serializable
          attribute :content, :string

          xml do
            element "body"
            map_all_content to: :content
          end

          # The source text with XML entities DECODED (`&lt;` → `<`).
          #
          # `content` is markup-encoded by design: map_all_content keeps
          # the raw inner markup so to_xml can re-emit it verbatim
          # (roundtrip fidelity). Consumers that display the code as
          # text need the decoded form — without it they double-escape
          # (`&amp;lt;`) or hand-roll fragile gsub chains. Comments in
          # the listing stay literal ("<!-- ... -->").
          def decoded_content
            CGI.unescapeHTML(Array(content).join)
          end
        end
      end
    end
  end
end
