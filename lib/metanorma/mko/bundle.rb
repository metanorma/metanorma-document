# frozen_string_literal: true

module Metanorma
  module Mko
    # The on-disk bundle writer: one place that knows the file layout,
    # the manifest bookkeeping, and the hash verification inputs. The
    # projection Writer and the collection exporter both compose it —
    # bundle mechanics are never duplicated.
    class Bundle
      attr_reader :dir

      def self.open(short, to)
        new(File.expand_path(File.join(to, "#{short}.mko")))
      end

      def initialize(dir)
        @dir = dir
        @manifest = Schema::Manifest.new(
          schema: SCHEMA, schema_version: SCHEMA_VERSION,
          generated: Schema::Generated.new(
            tool: "metanorma-document", schema_version: SCHEMA_VERSION,
          ),
          components: []
        )
        FileUtils.rm_rf(dir)
        FileUtils.mkdir_p(dir)
      end

      def add_json(name, file, object)
        path = File.join(dir, file)
        File.write(path, JSON.pretty_generate(JSON.parse(object.to_json)))
        component(name: name, file: file, media_type: "application/json")
      end

      # Line-oriented component; the block serializes each item
      # (framework to_json by default).
      def add_lines(name, file, items, &serializer)
        serializer ||= lambda(&:to_json)
        path = File.join(dir, file)
        File.write(path, "#{items.map(&serializer).join("\n")}\n")
        component(name: name, file: file, media_type: "application/jsonl",
                  count: items.size)
      end

      def add_asset(entry)
        path = File.join(dir, entry.name)
        FileUtils.mkdir_p(File.dirname(path))
        File.binwrite(path, entry.data)
        component(name: entry.name, file: entry.name,
                  media_type: entry.media_type, count: 1)
      end

      def flavor=(flavor)
        @manifest.generated.flavor = flavor
      end

      def source_file=(source)
        @manifest.source_file = source
      end

      def write_manifest
        @manifest.generated.timestamp = Time.now.utc.iso8601
        File.write(File.join(dir, "manifest.json"),
                   JSON.pretty_generate(JSON.parse(@manifest.to_json)))
        dir
      end

      def zip!
        require "zip"
        zip_path = "#{dir}.zip"
        Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
          Dir[File.join(dir, "**", "*")].each do |f|
            next if File.directory?(f)

            zipfile.add(f.sub("#{dir}/", ""), f)
          end
        end
        zip_path
      end

      private

      def component(name:, file:, media_type:, count: nil)
        @manifest.components << Schema::ManifestComponent.new(
          name: name, file: file, media_type: media_type,
          count: count, hash: "sha256:#{Digest::SHA256.file(File.join(dir, file)).hexdigest}"
        )
      end
    end
  end
end
