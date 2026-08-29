# frozen_string_literal: true

module Metanorma
  module Mko
    # Maps a projection Result onto a bundle directory (or zip). The
    # on-disk mechanics live in Bundle; this class only decides which
    # components a document projection produces.
    module Writer
      class << self
        def write(result, to:, zip: false)
          bundle = Bundle.open(result.document.ids.short, to)
          bundle.flavor = result.flavor
          add_components(bundle, result)
          bundle.write_manifest
          zip ? bundle.zip! : bundle.dir
        end

        private

        def add_components(bundle, result)
          bundle.add_json("document", "document.json", result.document)
          # bibdata/glossary/identifiers carry the NATIVE object-model
          # serializations (Relaton::Bib, Glossarist::Concept, Pubid),
          # produced by Document::NativeModels at the model layer.
          if result.bibdata
            bundle.add_json("bibdata", "bibdata.json", result.bibdata)
          end
          bundle.add_json("identifiers", "identifiers.json", result.identifiers)
          bundle.add_json("glossary", "glossary.json",
                          { "concepts" => result.glossary.map do |c|
                            JSON.parse(c.to_json)
                          end })
          # bibliography.jsonl: every cited document as native objects —
          # Relaton item + pubid parse — keyed to its reference unit.
          bib_lines = result.bibliography.map do |e|
            {
              "unit" => "u:#{e.key}",
              "citeas" => e.citeas,
              "pubid" => e.pubid && JSON.parse(e.pubid.to_json),
              "pubid_render" => e.pubid&.to_s,
              "bibitem" => e.item && JSON.parse(e.item.to_json),
            }
          end
          bundle.add_lines("bibliography", "bibliography.jsonl", bib_lines) do |l|
            JSON.generate(l)
          end
          bundle.add_lines("units", "units.jsonl", result.units)
          bundle.add_lines("edges", "edges.jsonl", result.edges)
          result.assets.each { |entry| bundle.add_asset(entry) }
        end
      end
    end
  end
end
