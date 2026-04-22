# frozen_string_literal: true
# rubocop:disable all — standalone test task, not library code

require "yaml"
require "fileutils"
require "tmpdir"
require "net/http"
require "uri"
require "metanorma/document"
require "canon"

# Round-trip test for mn-samples-* GitHub Pages sites.
#
# Scrapes each site for XML file links, downloads them (semantic + presentation),
# parses through the document model, serializes back, and compares with Canon.
#
# Tasks:
#   rake 'roundtrip:site[SITE_URL,REPO_NAME]'    - Process one site
#   rake 'roundtrip:file[XML_PATH]'              - Process one local XML file
#   rake 'roundtrip:consolidate[REPORTS_DIR]'     - Merge all reports
module RoundtripSamples
  METANORMA_ROOTS = %w[
    iso-standard ogc-standard nist-standard ieee-standard
    ietf-standard iho-standard bipm-standard rsd-standard
    itu-standard jis-standard m3d-standard iec-standard
    unece-standard metanorma metanorma-collection
  ].freeze

  SKIP_PATH_PATTERNS = %w[
    /rxl
    /relaton
    /repos/
    .rfc.
  ].freeze

  HTTP_TIMEOUT = 30

  # Maps mn-samples-* repo name to the model class for round-tripping.
  # nil means no document model exists yet — reported as "no_model".
  FLAVOR_MODEL_MAP = {
    "iso"     => Metanorma::IsoDocument::Root,
    "iec"     => Metanorma::IecDocument::Root,
    "ieee"    => Metanorma::IeeeDocument::Root,
    "oiml"    => Metanorma::OimlDocument::Root,
    "iho"     => Metanorma::IhoDocument::Root,
    "cc"      => Metanorma::CcDocument::Root,
    "bipm"    => Metanorma::BipmDocument::Root,
    "itu"     => Metanorma::ItuDocument::Root,
    "ogc"     => Metanorma::OgcDocument::Root,
    "ribose"  => Metanorma::RiboseDocument::Root,
    "ietf"    => Metanorma::IetfDocument::Root,
    "csa"     => nil,
    "un"      => nil,
  }.freeze

  module_function

  # --- Entry Points ---

  def run_site(site_url, repo_name)
    xml_urls = discover_xml_urls(site_url)

    if xml_urls.empty?
      report = empty_report(repo_name)
      write_report(repo_name, report)
      print_repo_summary(report)
      return
    end

    puts "Discovered #{xml_urls.size} XML files from #{repo_name}..."

    tmpdir = File.join(Dir.tmpdir, "roundtrip_#{repo_name}_#{Process.pid}")
    FileUtils.mkdir_p(tmpdir)

    begin
      results = xml_urls.map { |href| process_url(site_url, href, tmpdir, repo_name) }
      report = build_report(repo_name, results)
      write_report(repo_name, report)
      print_repo_summary(report)
    ensure
      FileUtils.rm_rf(tmpdir)
    end
  end

  def process_single(xml_path)
    result = process_file(xml_path)
    puts YAML.dump(result)
  end

  def consolidate(reports_dir)
    reports = load_reports(reports_dir)
    return puts("No reports found in #{reports_dir}") if reports.empty?

    summary = build_consolidated(reports)
    write_consolidated(summary)
    print_consolidated(summary)

    exit(1) if summary["total_failed"].positive? || summary["total_errors"].positive?
  end

  # --- Site Scraping ---

  def discover_xml_urls(site_url)
    base = site_url.chomp("/")
    html = http_get(base + "/")
    return [] unless html

    html.scan(/href="([^"]*\.xml)"/).flatten.select do |href|
      next false if href.start_with?("http") && !href.start_with?(base)
      next false if SKIP_PATH_PATTERNS.any? { |p| href.include?(p) }
      next false if href.include?("presentation.xml")
      true
    end.uniq.sort
  end

  def http_get(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = HTTP_TIMEOUT
    http.read_timeout = HTTP_TIMEOUT
    resp = http.get(uri.request_uri)
    return nil unless resp.is_a?(Net::HTTPSuccess)
    resp.body
  rescue StandardError => e
    warn "HTTP GET failed for #{url}: #{e.message}"
    nil
  end

  def download_xml(site_url, href, tmpdir)
    base = site_url.chomp("/")
    path = href.sub(%r{^\./}, "")
    url = href.start_with?("http") ? href : "#{base}/#{path}"
    relative = href.sub(%r{^\./}, "").sub(%r{^/}, "")
    local_path = File.join(tmpdir, relative)
    FileUtils.mkdir_p(File.dirname(local_path))
    content = http_get(url)
    return nil unless content
    File.write(local_path, content)
    local_path
  end

  # --- URL-Based Processing ---

  def process_url(site_url, href, tmpdir, repo_name)
    base = site_url.chomp("/")
    remote_name = href.sub(%r{^\./}, "")
    display = remote_name

    result = {
      "file" => display,
      "original_root" => "unknown",
      "status" => "error",
      "error" => nil,
      "normative_diffs" => 0,
      "informative_diffs" => 0,
      "differences" => [],
    }

    # Download semantic XML
    local = download_xml(site_url, href, tmpdir)
    unless local
      result["error"] = "Failed to download #{display}"
      return result
    end

    process_local_file(local, result, repo_name)

    # Also test presentation XML if it exists
    pres_href = href.sub(/\.xml$/, ".presentation.xml")
    pres_local = download_xml(site_url, pres_href, tmpdir)
    if pres_local
      pres_result = {
        "file" => remote_name.sub(/\.xml$/, ".presentation.xml"),
        "original_root" => "unknown",
        "status" => "error",
        "error" => nil,
        "normative_diffs" => 0,
        "informative_diffs" => 0,
        "differences" => [],
      }
      process_local_file(pres_local, pres_result, repo_name)
      return [result, pres_result]
    end

    result
  end

  def process_local_file(local_path, result, repo_name = nil)
    original = File.read(local_path, encoding: "UTF-8")
    result["original_root"] = extract_root_name(original)

    begin
      model = resolve_model(original, repo_name)
      if model.nil?
        result["status"] = "no_model"
        result["error"] = "No document model implemented for flavor '#{repo_name}'"
        return
      end

      doc = model.from_xml(original)
      roundtrip = doc.to_xml

      cmp = Canon::Comparison.equivalent?(
        original, roundtrip,
        format: :xml,
        match_profile: :spec_friendly,
        match: {
          attribute_order: :ignore,
          attribute_values: :normalize,
        },
        verbose: true,
      )

      norm = cmp.normative_differences
      info = cmp.informative_differences

      result["status"] = norm.empty? ? "pass" : "fail"
      result["normative_diffs"] = norm.size
      result["informative_diffs"] = info.size
      result["differences"] = serialize_diffs(cmp.differences)
    rescue StandardError => e
      result["status"] = "error"
      result["error"] = "#{e.class}: #{e.message}"
      result["backtrace"] = e.backtrace&.first(5)
    end
  end

  # --- Local File Processing ---

  def process_file(xml_path)
    original = File.read(xml_path, encoding: "UTF-8")

    result = {
      "file" => xml_path,
      "original_root" => extract_root_name(original),
      "status" => "error",
      "error" => nil,
      "normative_diffs" => 0,
      "informative_diffs" => 0,
      "differences" => [],
    }

    process_local_file(xml_path, result, nil)
    result
  end

  # --- XML Helpers ---

  # Maps root element names to model classes for auto-detection
  ROOT_MODEL_MAP = {
    "iso-standard"       => -> { Metanorma::IsoDocument::Root },
    "iec-standard"       => -> { Metanorma::IecDocument::Root },
    "ieee-standard"      => -> { Metanorma::IeeeDocument::Root },
    "ogc-standard"       => -> { Metanorma::OgcDocument::Root },
    "itu-standard"       => -> { Metanorma::ItuDocument::Root },
    "bipm-standard"      => -> { Metanorma::BipmDocument::Root },
    "nist-standard"      => -> { Metanorma::IsoDocument::Root },
    "iho-standard"       => -> { Metanorma::IhoDocument::Root },
    "rsd-standard"       => -> { Metanorma::RiboseDocument::Root },
    "ietf-standard"      => -> { Metanorma::IetfDocument::Root },
    "cc-standard"        => -> { Metanorma::CcDocument::Root },
    "metanorma"          => -> { Metanorma::IsoDocument::Root },
    "metanorma-collection" => -> { Metanorma::Collection::Root },
    "m3d-standard"        => -> { Metanorma::IsoDocument::Root },
  }.freeze

  def resolve_model(xml, repo_name)
    if repo_name
      model = FLAVOR_MODEL_MAP[repo_name]
      return model if model
    end

    # Auto-detect from XML root element or metanorma/@flavor
    if xml.include?("<metanorma-collection")
      return Metanorma::Collection::Root
    end

    root_name = extract_root_name(xml)

    # Check for <metanorma flavor="...">
    if xml =~ /<metanorma[^>]*flavor="([^"]*)"/
      flavor = Regexp.last_match(1)
      model = FLAVOR_MODEL_MAP[flavor]
      return model if model
    end

    # Fallback: map root element name
    factory = ROOT_MODEL_MAP[root_name]
    return factory.call if factory

    nil
  end

  def extract_root_name(xml)
    xml.each_line do |line|
      stripped = line.strip
      next if stripped.empty? || stripped.start_with?("<?", "<!--", "<!DOCTYPE")
      return Regexp.last_match(1) if stripped =~ /<([a-z][a-z0-9-]*)/
    end
    "unknown"
  end

  def serialize_diffs(diffs)
    diffs.first(50).map do |d|
      next { "raw" => d.to_s } unless d.is_a?(Canon::Diff::DiffNode)

      h = {
        "dimension" => d.dimension.to_s,
        "reason" => d.reason,
        "normative" => d.normative?,
        "formatting" => d.formatting?,
      }
      h["path"] = d.path if d.path
      h["before"] = truncate_str(d.serialized_before, 300) if d.serialized_before
      h["after"] = truncate_str(d.serialized_after, 300) if d.serialized_after
      h["attributes_before"] = d.attributes_before if d.attributes_before.is_a?(Hash)
      h["attributes_after"] = d.attributes_after if d.attributes_after.is_a?(Hash)
      h
    end
  end

  def truncate_str(str, max)
    str.length > max ? "#{str[0, max]}..." : str
  end

  # --- Report Building ---

  def build_report(repo_name, raw_results)
    results = raw_results.flatten
    {
      "repo" => repo_name,
      "timestamp" => Time.now.utc.iso8601,
      "total_files" => results.size,
      "passed" => results.count { |r| r["status"] == "pass" },
      "failed" => results.count { |r| r["status"] == "fail" },
      "errors" => results.count { |r| r["status"] == "error" },
      "no_model" => results.count { |r| r["status"] == "no_model" },
      "files" => results,
    }
  end

  def empty_report(repo_name)
    {
      "repo" => repo_name,
      "timestamp" => Time.now.utc.iso8601,
      "total_files" => 0,
      "passed" => 0,
      "failed" => 0,
      "errors" => 0,
      "no_model" => 0,
      "files" => [],
    }
  end

  def write_report(repo_name, report)
    dir = File.join(Dir.pwd, "tmp", "roundtrip_reports")
    FileUtils.mkdir_p(dir)
    path = File.join(dir, "#{repo_name}.yml")
    File.write(path, YAML.dump(report))
    puts "Report: #{path}"
  end

  def load_reports(dir)
    Dir[File.join(dir, "**", "*.yml")].filter_map do |path|
      YAML.safe_load_file(path, permitted_classes: [Symbol, Time])
    rescue StandardError => e
      warn "Skip #{path}: #{e.message}"
      nil
    end.select { |r| r.is_a?(Hash) && r.key?("repo") }
  end

  def build_consolidated(reports)
    {
      "timestamp" => Time.now.utc.iso8601,
      "total_repos" => reports.size,
      "total_files" => reports.sum { |r| r["total_files"].to_i },
      "total_passed" => reports.sum { |r| r["passed"].to_i },
      "total_failed" => reports.sum { |r| r["failed"].to_i },
      "total_errors" => reports.sum { |r| r["errors"].to_i },
      "total_no_model" => reports.sum { |r| r["no_model"].to_i },
      "repos" => reports.sort_by { |r| r["repo"] },
    }
  end

  def write_consolidated(summary)
    dir = File.join(Dir.pwd, "tmp")
    FileUtils.mkdir_p(dir)
    path = File.join(dir, "roundtrip_consolidated.yml")
    File.write(path, YAML.dump(summary))
  end

  # --- Terminal Output ---

  def color(code)
    "\e[#{code}m"
  end

  def print_repo_summary(report)
    b = color(1); g = color(32); r = color(31); y = color(33); c = color(36); rst = color(0)
    t = report["total_files"]; p = report["passed"]; f = report["failed"]
    e = report["errors"]; nm = report["no_model"] || 0

    puts
    parts = ["#{b}#{report['repo']}#{rst}: #{t} files"]
    parts << "#{g}#{p} pass#{rst}" if p.positive?
    parts << "#{r}#{f} fail#{rst}" if f.positive?
    parts << "#{y}#{e} error#{rst}" if e.positive?
    parts << "#{c}#{nm} no model#{rst}" if nm.positive?
    puts parts.join(" | ")

    report["files"]&.each do |fl|
      case fl["status"]
      when "fail"
        puts "  #{r}FAIL#{rst} #{fl['file']} (#{fl['normative_diffs']} norm, #{fl['informative_diffs']} info diffs)"
      when "error"
        puts "  #{y}ERR #{rst} #{fl['file']}: #{fl['error']}"
      when "no_model"
        puts "  #{c}NO_MODEL#{rst} #{fl['file']}"
      end
    end
  end

  def print_consolidated(summary)
    b = color(1); g = color(32); r = color(31); y = color(33); c = color(36); rst = color(0)
    tf = summary["total_files"]; tp = summary["total_passed"]
    tfa = summary["total_failed"]; te = summary["total_errors"]
    tnm = summary["total_no_model"] || 0
    testable = tf - tnm
    rate = testable.positive? ? format("%.1f%%", tp.to_f / testable * 100) : "N/A"

    puts
    puts "=" * 80
    puts "#{b}ROUNDTRIP CONSOLIDATED REPORT#{rst}"
    puts "=" * 80
    puts "  #{c}Timestamp:#{rst} #{summary['timestamp']}"
    puts "  #{c}Repos:#{rst}     #{summary['total_repos']}"
    puts "  #{c}Files:#{rst}     #{tf} (#{testable} testable, #{c}#{tnm} no model#{rst})"
    puts "  #{c}Results:#{rst}   #{g}#{tp} pass#{rst} | #{r}#{tfa} fail#{rst} | #{y}#{te} error#{rst} | Rate: #{rate}"
    puts
    puts "-" * 80
    printf "  %-15s %6s %6s %6s %6s %6s %8s\n", "Repo", "Total", "Pass", "Fail", "Error", "NoMod", "Rate"
    puts "  #{'-' * 59}"

    summary["repos"].each do |repo|
      t = repo["total_files"].to_i; p = repo["passed"].to_i
      f = repo["failed"].to_i; e = repo["errors"].to_i
      nm = (repo["no_model"] || 0).to_i
      testable_repo = t - nm
      rt = testable_repo.positive? ? format("%.1f%%", p.to_f / testable_repo * 100) : "N/A"
      marker = nm == t ? c : ((f.positive? || e.positive?) ? r : (t.positive? ? g : y))
      printf "  #{marker}%-15s#{rst} %6d %6d %6d %6d %6d %8s\n", repo["repo"], t, p, f, e, nm, rt
    end

    # Unimplemented flavors section
    no_model_repos = summary["repos"].select { |repo| (repo["no_model"] || 0).to_i.positive? }
    if no_model_repos.any?
      puts
      puts "-" * 80
      puts "#{b}#{c}UNIMPLEMENTED FLAVORS (no document model)#{rst}"
      puts "-" * 80
      no_model_repos.each do |repo|
        nm = (repo["no_model"] || 0).to_i
        puts "  #{c}NO_MODEL#{rst} #{repo['repo']} (#{nm} file#{nm == 1 ? '' : 's'})"
        (repo["files"] || []).select { |f| f["status"] == "no_model" }.first(5).each do |f|
          puts "           #{f['file']}"
        end
        remaining = nm - 5
        puts "           ... and #{remaining} more" if remaining.positive?
      end
    end

    failed = summary["repos"].flat_map do |repo|
      (repo["files"] || []).select { |f| f["status"] == "fail" }.map { |f| f.merge("repo" => repo["repo"]) }
    end
    if failed.any?
      puts
      puts "-" * 80
      puts "#{b}#{r}FAILED FILES (#{failed.size})#{rst}"
      puts "-" * 80
      failed.first(40).each do |f|
        puts "  #{r}FAIL#{rst} [#{f['repo']}] #{f['file']} (#{f['normative_diffs']} norm, #{f['informative_diffs']} info)"
      end
      puts "  ... and #{failed.size - 40} more" if failed.size > 40
    end

    errored = summary["repos"].flat_map do |repo|
      (repo["files"] || []).select { |f| f["status"] == "error" }.map { |f| f.merge("repo" => repo["repo"]) }
    end
    if errored.any?
      puts
      puts "-" * 80
      puts "#{b}#{y}ERRORED FILES (#{errored.size})#{rst}"
      puts "-" * 80
      errored.first(30).each do |f|
        puts "  #{y}ERR #{rst} [#{f['repo']}] #{f['file']}"
        puts "       #{f['error']}" if f["error"]
      end
      puts "  ... and #{errored.size - 30} more" if errored.size > 30
    end

    puts
    puts "=" * 80
    status = (tfa.positive? || te.positive?) ? "#{r}HAS FAILURES#{rst}" : "#{g}ALL PASSING#{rst}"
    unimpl = tnm.positive? ? " (#{c}#{tnm} files have no model#{rst})" : ""
    puts "#{b}Result: #{status}#{unimpl}#{rst}"
    puts "=" * 80
    puts
  end
end

namespace :roundtrip do
  desc "Round-trip test all metanorma XML files from a GitHub Pages site"
  task :site, [:site_url, :repo_name] do |_t, args|
    site_url = args[:site_url] || abort("Usage: rake 'roundtrip:site[URL,NAME]'")
    repo_name = args[:repo_name] || begin
      uri = URI(site_url)
      File.basename(uri.path).sub(/^mn-samples-/, "")
    end
    RoundtripSamples.run_site(site_url, repo_name)
  end

  desc "Round-trip test a single local XML file"
  task :file, [:xml_path] do |_t, args|
    xml_path = args[:xml_path] || abort("Usage: rake 'roundtrip:file[PATH]'")
    RoundtripSamples.process_single(xml_path)
  end

  desc "Consolidate round-trip reports and display summary"
  task :consolidate, [:reports_dir] do |_t, args|
    reports_dir = args[:reports_dir] || "tmp/roundtrip_reports"
    RoundtripSamples.consolidate(reports_dir)
  end
end
# rubocop:enable all
