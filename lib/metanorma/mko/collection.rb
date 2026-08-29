# frozen_string_literal: true

require "yaml"

module Metanorma
  module Mko
    # Collection export (MN 116 §collections): a metanorma
    # collection.yml declares a document family (OIML R 60 parts,
    # amendments, R 129/138/144). Every member document exports as its
    # own bundle (the document bundle is the unit of truth); the
    # collection adds one small bundle with the membership contract:
    # collection.json and the cross-document part_of edges binding the
    # members to the family. Member identity comes from each member's
    # exported document.json — the collection yml's identifiers are
    # reference labels only.
    class Collection
      Member = Struct.new(:fileref, :xml_path, :identifier,
                          :bundle_path, :skipped, keyword_init: true)

      class Result
        attr_reader :collection_bundle, :members

        def initialize(collection_bundle:, members:)
          @collection_bundle = collection_bundle
          @members = members
        end

        def skipped
          members.select(&:skipped)
        end
      end

      class << self
        def export(yml, to:, assets_from: nil, zip: false)
          new(yml, to: to, assets_from: assets_from, zip: zip).export
        end
      end

      def initialize(yml, to:, assets_from: nil, zip: false)
        @yml = if yml.is_a?(Hash)
                 yml
               elsif File.exist?(yml.to_s)
                 YAML.safe_load_file(yml)
               else
                 YAML.safe_load(yml)
               end
        @base = File.exist?(yml.to_s) ? File.dirname(File.expand_path(yml.to_s)) : Dir.pwd
        @to = to
        @assets_from = assets_from
        @zip = zip
      end

      def export
        members = docrefs.filter_map do |ref|
          member = resolve_member(ref)
          next member if member.skipped

          member.bundle_path = Mko.export(
            File.read(member.xml_path), to: @to,
                                        presentation_xml: presentation_for(member.xml_path),
                                        assets_from: @assets_from || File.dirname(member.xml_path)
          )
          member
        end
        Result.new(collection_bundle: write_collection_bundle(members),
                   members: members)
      end

      private

      def docrefs
        manifest = @yml["manifest"]
        manifest = manifest.first if manifest.is_a?(Array)
        Array(manifest.is_a?(Hash) ? manifest["docref"] : nil)
      rescue StandardError
        []
      end

      # The yml points members at .adoc sources; the compiled semantic
      # XML sits beside them. Direct .xml filerefs work too.
      def resolve_member(ref)
        fileref = ref["fileref"].to_s
        xml = fileref.end_with?(".xml") ? fileref : fileref.sub(/\.adoc$/, ".xml")
        path = File.expand_path(xml, @base)
        if File.file?(path)
          Member.new(fileref: fileref, xml_path: path,
                     identifier: ref["identifier"])
        else
          Member.new(fileref: fileref, xml_path: path,
                     identifier: ref["identifier"], skipped: true)
        end
      end

      def presentation_for(xml_path)
        pres = xml_path.sub(/\.xml$/, ".presentation.xml")
        File.file?(pres) ? File.read(pres) : nil
      end

      def canonical
        docid = @yml.dig("bibdata", "docid")
        docid = docid.first if docid.is_a?(Array)
        docid.is_a?(Hash) ? docid["id"].to_s : docid.to_s
      end

      def title
        t = @yml.dig("bibdata", "title")
        t = t.first if t.is_a?(Array)
        t.is_a?(Hash) ? t["content"].to_s : t.to_s
      end

      def collection_short
        Mko.slug(canonical.empty? ? "collection" : canonical)
      end

      def member_data(member)
        document = JSON.parse(File.read(File.join(member.bundle_path,
                                                  "document.json")))
        short = document.dig("ids", "short")
        { "bundle" => "#{short}.mko",
          "docidentifier" => document.dig("ids", "canonical"),
          "identifier" => member.identifier,
          "title" => Array(document["titles"]).first.to_h["text"],
          "edition" => document["edition"] }
      rescue StandardError
        nil
      end

      def collection_member(member)
        data = member_data(member) or return nil

        Schema::CollectionMember.new(
          bundle: data["bundle"], docidentifier: data["docidentifier"],
          identifier: data["identifier"], title: data["title"],
          edition: data["edition"]
        )
      end

      def write_collection_bundle(members)
        collection = Schema::Collection.new(
          canonical: canonical, short: collection_short, title: title,
          edition: @yml.dig("bibdata", "edition"),
          members: members.filter_map { |m| collection_member(m) }
        )
        # A member whose identity collides with the family (e.g. a
        # stale amendment bibdata — mn-samples-oiml#66) would emit a
        # self-edge; skip those, they say nothing.
        edges = collection.members.reject do |m|
          m.docidentifier.to_s.empty? || m.docidentifier == collection.canonical
        end.map do |m|
          { "from" => "doc:#{m.docidentifier}",
            "to" => "doc:#{collection.canonical}",
            "kind" => "part_of" }
        end
        bundle = Bundle.open(collection_short, @to)
        bundle.flavor = nil
        bundle.add_json("collection", "collection.json", collection)
        bundle.add_lines("edges", "edges.jsonl", edges) do |edge|
          JSON.generate(edge)
        end
        bundle.write_manifest
        @zip ? bundle.zip! : bundle.dir
      end
    end
  end
end
