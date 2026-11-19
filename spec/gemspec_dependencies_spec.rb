# frozen_string_literal: true

require "spec_helper"

# Every gem lib code requires at load time must be a declared runtime
# dependency, or the gem cannot load on a fresh install
# (metanorma-document#129: require "metanorma/mirror" shipped undeclared,
# breaking standalone installs of 0.5.9/0.5.10).
#
# The gemspec is read as text — packaging is not loaded through the Gem
# API inside specs. Requires that resolve to this gem's own lib files,
# to the standard library, or to interpolated (non-static) paths are
# exempt.
RSpec.describe "the gemspec declares every load-time require" do
  subject(:undeclared_requires) do
    requires = Hash.new { |h, k| h[k] = [] }
    Dir[File.join(lib_dir, "**", "*.rb")].each do |file|
      relative = file.delete_prefix("#{lib_dir}/")
      File.readlines(file).each_with_index do |line, i|
        match = line.match(/^\s*require\s+["']([^"']+)["']/) or next
        path = match[1]
        next if path.include?("#")
        next if File.exist?(File.join(lib_dir, "#{path}.rb"))

        segments = path.split("/")
        candidates = (1..segments.size).map do |n|
          segments.first(n).join("-")
        end
        next if candidates.any? { |c| declared_gems.include?(c) }
        next if stdlib_gems.include?(path)

        requires[path] << "#{relative}:#{i + 1}"
      end
    end
    requires
  end

  let(:gemspec_path) do
    File.join(__dir__, "..", "metanorma-document.gemspec")
  end

  let(:lib_dir) do
    File.join(__dir__, "..", "lib")
  end

  let(:declared_gems) do
    File.readlines(gemspec_path)
      .join
      .scan(/add_(?:runtime_)?dependency\s+["']([\w-]+)["']/)
      .flatten
  end

  let(:stdlib_gems) do
    %w[
      base64 bigdecimal cgi csv date delegate digest drb English erb
      fileutils forwardable getoptlong ipaddr json monitor net/http
      openssl optparse pathname psych rbconfig securerandom set
      shellwords singleton stringio strscan tempfile time tmpdir tsort
      uri yaml zlib
    ]
  end

  it "declares a runtime dependency for every gem lib code requires" do
    expect(undeclared_requires).to be_empty,
                                   "lib code requires gems the gemspec does not declare: " \
                                   "#{undeclared_requires.map { |k, v| "#{k} (#{v.join(', ')})" }.join('; ')}"
  end
end
