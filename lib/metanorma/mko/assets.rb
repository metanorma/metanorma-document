# frozen_string_literal: true

require "base64"
require "digest"

module Metanorma
  module Mko
    # Hash-addressed figure assets (MN 116 §assets). Bytes come from
    # the model when it carries them (data URIs) and from the caller's
    # source directory for relative paths — never from the walk's
    # environment. Every asset lands in the bundle as assets/<sha256>,
    # manifest-verified like every other component.
    class Assets
      Entry = Struct.new(:name, :media_type, :data, keyword_init: true)

      DATA_URI = /\Adata:([^;,]+)(?:;charset=[^;,]+)?;base64,(.*)\z/m.freeze
      MEDIA_TYPES = {
        ".png" => "image/png", ".jpg" => "image/jpeg", ".jpeg" => "image/jpeg",
        ".gif" => "image/gif", ".svg" => "image/svg+xml",
        ".tif" => "image/tiff", ".tiff" => "image/tiff", ".webp" => "image/webp",
      }.freeze

      def initialize(source_dir: nil)
        @source_dir = source_dir
        @entries = {}
      end

      # Returns the asset reference ("assets/<sha256>") for a figure
      # source, or nil when no bytes are available.
      def attach(uri)
        data, media_type = bytes_for(uri)
        return nil unless data

        sha = Digest::SHA256.hexdigest(data)
        name = "assets/#{sha}"
        @entries[name] ||= Entry.new(
          name: name, media_type: media_type || media_type_for(uri), data: data
        )
        name
      end

      def entries
        @entries.values
      end

      private

      def bytes_for(uri)
        text = uri.to_s
        if (m = text.match(DATA_URI))
          [Base64.decode64(m[2]), m[1]]
        elsif @source_dir && !text.empty?
          path = File.expand_path(text, @source_dir)
          [File.binread(path), nil] if File.file?(path)
        end
      end

      def media_type_for(uri)
        MEDIA_TYPES[File.extname(uri.to_s).downcase] || "application/octet-stream"
      end
    end
  end
end
