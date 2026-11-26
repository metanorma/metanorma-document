# frozen_string_literal: true

begin
  # The provision index streams the sibling presentation XML with
  # Nokogiri's Reader; without it the index is unavailable and
  # requirements fall back to their semantic components. Flavors
  # wiring a presentation XML (the ISO profile) carry nokogiri.
  require "nokogiri" # soft-require: LoadError-guarded optional integration
rescue LoadError
  nil
end

module Metanorma
  module Document
    module Sts
      module Transformer
        # Index of requirement provision tables from the sibling
        # presentation XML (document.presentation.xml, produced by the
        # same compile). Every requirement that renders as a formal table
        # carries an <fmt-provision> wrapper around its fully-rendered
        # <table>; the wrapper sits inside the requirement element, whose
        # +anchor+ identifies the requirement on both the semantic and the
        # presentation tree.
        #
        # The scan is a streaming Nokogiri::XML::Reader pass: it never
        # builds a DOM of the (multi-megabyte) presentation file, and it
        # retains only the provision <table> fragments, parsed as typed
        # TableBlocks. Keyed by requirement anchor; RequirementTransformer
        # looks its table up by +requirement.anchor+.
        class ProvisionIndex
          REQ_ELEMENTS = %w[requirement recommendation permission].freeze

          def initialize(tables)
            @tables = tables
          end

          # Typed TableBlock for +anchor+, or nil when the presentation
          # XML is unavailable or the requirement carries no provision.
          def table_for(anchor)
            @tables[anchor]
          end

          def size
            @tables.size
          end

          class << self
            # Build from presentation XML text. Returns an empty index for
            # a nil/empty input (the standalone convert path, where no
            # presentation XML exists — requirements fall back to
            # synthesized tables).
            def from_xml(xml)
              return new({}) if xml.nil? || xml.empty?

              new(scan(xml))
            end

            private

            # Single streaming pass: track the stack of requirement-like
            # elements (their +anchor+), capture each <fmt-provision>'s
            # outer XML, and parse it as a typed TableBlock under the
            # enclosing requirement's anchor.
            def scan(xml)
              tables = {}
              anchor_stack = []
              capture_anchor = nil

              reader = Nokogiri::XML::Reader(xml)
              reader.each do |node|
                type = node.node_type
                if type == Nokogiri::XML::Reader::TYPE_ELEMENT
                  name = node.local_name
                  if REQ_ELEMENTS.include?(name)
                    anchor = node.attribute("anchor")
                    anchor_stack.push(anchor) if anchor && !anchor.empty?
                  elsif name == "fmt-provision"
                    capture_anchor = current_anchor(anchor_stack)
                    table = parse_provision_table(node.outer_xml)
                    tables[capture_anchor] = table if capture_anchor && table
                  end
                elsif type == Nokogiri::XML::Reader::TYPE_END_ELEMENT
                  name = node.local_name
                  anchor_stack.pop if REQ_ELEMENTS.include?(name)
                  capture_anchor = nil if name == "fmt-provision"
                end
              end
              tables
            end

            def current_anchor(stack)
              stack.last
            end

            # The <fmt-provision> outer XML holds a single <table>; parse
            # it as the typed TableBlock (fmt-name, autonum, thead/tbody
            # rows with full inline content).
            def parse_provision_table(fragment)
              table_xml = fragment
                .sub(/\A<fmt-provision\b[^>]*>/, "").delete_suffix("</fmt-provision>")
                .strip
              return nil unless table_xml.start_with?("<table")

              Metanorma::Document::Components::Tables::TableBlock.from_xml(table_xml)
            rescue StandardError
              nil
            end
          end
        end
      end
    end
  end
end
