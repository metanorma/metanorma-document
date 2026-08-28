# frozen_string_literal: true

module Metanorma
  module Mko
    # Writes a projection Result as an MKO bundle directory (or zip).
    # Each line of units.jsonl / edges.jsonl is the framework-generated
    # to_json of one schema object.
    module Writer
      class << self
        def write(result, to:, zip: false)
          dir = bundle_dir(result, to)
          FileUtils.rm_rf(dir)
          FileUtils.mkdir_p(dir)
          manifest = write_components(result, dir)
          File.write(File.join(dir, "manifest.json"),
                     JSON.pretty_generate(JSON.parse(manifest.to_json)))
          zip ? zip_bundle(dir) : dir
        end

        private

        def bundle_dir(result, to)
          name = (result.document.ids.short || "document") + ".mko"
          File.expand_path(File.join(to, name))
        end

        def write_components(result, dir)
          manifest = Schema::Manifest.new(
            schema: SCHEMA, schema_version: SCHEMA_VERSION,
            generated: Schema::Generated.new(
              tool: "metanorma-document", schema_version: SCHEMA_VERSION,
              flavor: result.flavor, timestamp: Time.now.utc.iso8601
            ),
            components: []
          )
          add_component(manifest, dir, "document", "document.json",
                        "application/json", result.document)
          # bibdata/glossary/identifiers carry the NATIVE object-model
          # serializations (Relaton::Bib, Glossarist::Concept, Pubid),
          # produced by Document::NativeModels at the model layer.
          if result.bibdata
            add_component(manifest, dir, "bibdata", "bibdata.json",
                          "application/json", result.bibdata)
          end
          add_component(manifest, dir, "identifiers", "identifiers.json",
                        "application/json", result.identifiers)
          glossary = { "concepts" => result.glossary.map do |c|
            JSON.parse(c.to_json)
          end }
          add_component(manifest, dir, "glossary", "glossary.json",
                        "application/json", glossary)
          # bibliography.jsonl: every cited document as native objects —
          # Relaton item + pubid parse — keyed to its reference unit, so
          # citation edges resolve to documents instead of strings.
          bib_lines = result.bibliography.map do |e|
            {
              "unit" => "u:#{e.key}",
              "citeas" => e.citeas,
              "pubid" => e.pubid && JSON.parse(e.pubid.to_json),
              "pubid_render" => e.pubid&.to_s,
              "bibitem" => e.item && JSON.parse(e.item.to_json),
            }
          end
          write_native_lines(manifest, dir, "bibliography",
                             "bibliography.jsonl", bib_lines)
          write_lines(manifest, dir, "units", "units.jsonl", result.units)
          write_lines(manifest, dir, "edges", "edges.jsonl", result.edges)
          manifest
        end

        def add_component(manifest, dir, name, file, media_type, object)
          path = File.join(dir, file)
          File.write(path, JSON.pretty_generate(JSON.parse(object.to_json)))
          manifest.components << Schema::ManifestComponent.new(
            name: name, file: file, media_type: media_type,
            hash: file_hash(path)
          )
        end

        # Line-oriented component whose values are already-serialized
        # native JSON objects (framework to_json upstream).
        def write_native_lines(manifest, dir, name, file, lines)
          path = File.join(dir, file)
          File.write(path, lines.map { |l| JSON.generate(l) }.join("\n") + "\n")
          manifest.components << Schema::ManifestComponent.new(
            name: name, file: file, media_type: "application/jsonl",
            count: lines.size, hash: file_hash(path)
          )
        end

        def write_lines(manifest, dir, name, file, objects)
          path = File.join(dir, file)
          File.write(path, objects.map(&:to_json).join("\n") + "\n")
          manifest.components << Schema::ManifestComponent.new(
            name: name, file: file, media_type: "application/jsonl",
            count: objects.size, hash: file_hash(path)
          )
        end

        def file_hash(path)
          "sha256:" + Digest::SHA256.file(path).hexdigest
        end

        def zip_bundle(dir)
          zip_path = dir + ".zip"
          require "zip"
          Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
            Dir[File.join(dir, "**", "*")].sort.each do |f|
              next if File.directory?(f)

              zipfile.add(f.sub(dir + "/", ""), f)
            end
          end
          zip_path
        end
      end
    end
  end
end
