# frozen_string_literal: true

require "cgi"

module Metanorma
  module Document
    module Components
      module AncillaryBlocks
        class SourcecodeBody < Lutaml::Model::Serializable
          attribute :content, :string

          xml do
            # Type-only (embedded) model: SourcecodeBlock carries the
            # <body> tag through its own `map_element "body"` mapping.
            # A root-level element declaration must NOT be added back:
            # with an element declared, lutaml-model drops the raw
            # map_all_content capture at the root (content comes out nil
            # on every 0.8.x in the supported range), while the embedded
            # path — the only one this class takes — round-trips it.
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
