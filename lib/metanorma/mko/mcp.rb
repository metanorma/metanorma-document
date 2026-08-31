# frozen_string_literal: true

require "json"

module Metanorma
  module Mko
    # Reference MCP server over an MKO bundle (issue #53 item 9; the
    # MN 116 contract: search_units / get_unit / walk_edges /
    # edition_diff). Every tool is a read over bundle files — an agent
    # consumes a Metanorma corpus without anyone building a RAG first.
    # JSON-RPC 2.0 over stdio; drive via #handle lines or #run(io).
    module Mcp
      class Server
        PROTOCOL = "2025-06-18"
        TOOLS = [
          { "name" => "search_units",
            "description" => "Search the document's units by term " \
                             "overlap over title and text; optional type filter",
            "inputSchema" => {
              "type" => "object",
              "properties" => {
                "query" => { "type" => "string" },
                "type" => { "type" => "string",
                            "enum" => %w[clause annex term table figure formula
                                        note example sourcecode requirement
                                        reference] },
              },
              "required" => %w[query],
            } },
          { "name" => "get_unit",
            "description" => "Full unit by stable id (text + typed payload)",
            "inputSchema" => {
              "type" => "object",
              "properties" => { "id" => { "type" => "string" } },
              "required" => %w[id],
            } },
          { "name" => "walk_edges",
            "description" => "Edges touching a unit (any kind, or one kind)",
            "inputSchema" => {
              "type" => "object",
              "properties" => {
                "unit_id" => { "type" => "string" },
                "kind" => { "type" => "string" },
              },
            } },
          { "name" => "edition_diff",
            "description" => "Structured change set between two bundles of " \
                             "the same document (anchors pair; hashes decide)",
            "inputSchema" => {
              "type" => "object",
              "properties" => {
                "bundle_a" => { "type" => "string" },
                "bundle_b" => { "type" => "string" },
              },
              "required" => %w[bundle_a bundle_b],
            } },
        ].freeze

        def initialize(bundle)
          @bundle = bundle
        end

        # One JSON-RPC request line -> response line (or nil for
        # notifications). The test surface: drive the protocol without
        # spawning a process.
        def handle(line)
          req = JSON.parse(line)
          return nil if req["id"].nil?

          result =
            case req["method"]
            when "initialize"
              { "protocolVersion" => PROTOCOL,
                "capabilities" => { "tools" => {} },
                "serverInfo" => { "name" => "metanorma-mko",
                                  "version" => SCHEMA_VERSION } }
            when "tools/list" then { "tools" => TOOLS }
            when "tools/call" then call_tool(req["params"] || {})
            end
          return JSON.generate(
            { "jsonrpc" => "2.0", "id" => req["id"],
              "error" => { "code" => -32_601,
                           "message" => "method not found: #{req['method']}" } }
          ) if result.nil?

          JSON.generate({ "jsonrpc" => "2.0", "id" => req["id"],
                          "result" => result })
        rescue StandardError => e
          JSON.generate({ "jsonrpc" => "2.0", "id" => (req && req["id"]),
                          "error" => { "code" => -32_603,
                                       "message" => "#{e.class}: #{e.message}" } })
        end

        def run(io = $stdin)
          io.each_line { |line| (out = handle(line)) && puts(out) }
        end

        private

        def units
          @units ||= File.readlines(File.join(@bundle, "units.jsonl"))
                         .map { |l| JSON.parse(l) }
        end

        def edges
          @edges ||= File.readlines(File.join(@bundle, "edges.jsonl"))
                         .map { |l| JSON.parse(l) }
        end

        def call_tool(params)
          name = params["name"]
          args = params["arguments"] || {}
          case name
          when "search_units" then search_units(args)
          when "get_unit" then get_unit(args)
          when "walk_edges" then walk_edges(args)
          when "edition_diff" then edition_diff(args)
          else raise ArgumentError, "unknown tool: #{name}"
          end
        end

        def search_units(args)
          terms = args["query"].to_s.downcase.split(/[^\p{L}\p{N}]+/)
                              .reject { |t| t.length < 2 }
          pool = args["type"] ? units.select { |u| u["type"] == args["type"] } : units
          scored = pool.filter_map do |u|
            hay = "#{u['title']} #{u['text']}".downcase
            score = terms.count { |t| hay.include?(t) }
            { "id" => u["id"], "type" => u["type"], "anchor" => u["anchor"],
              "number" => u["number"], "title" => u["title"],
              "score" => score } if score.positive?
          end
          text(JSON.generate(scored.sort_by { |s| -s["score"] }.first(10)))
        end

        def get_unit(args)
          unit = units.find { |u| u["id"] == args["id"] }
          raise ArgumentError, "no unit #{args['id']}" unless unit

          text(JSON.generate(unit))
        end

        def walk_edges(args)
          picked = edges.select do |e|
            (args["unit_id"].nil? || e["from"] == args["unit_id"] ||
             e["to"] == args["unit_id"]) &&
              (args["kind"].nil? || e["kind"] == args["kind"])
          end
          text(JSON.generate(picked.first(50)))
        end

        def edition_diff(args)
          text(JSON.generate(Diff.between(args["bundle_a"], args["bundle_b"])))
        end

        def text(body)
          { "content" => [{ "type" => "text", "text" => body }] }
        end
      end
    end
  end
end
