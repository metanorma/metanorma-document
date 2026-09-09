# frozen_string_literal: true

require "json"
require "open3"
require "rbconfig"

desc "Audit flavor repos: parse + HTML-generate presentation fixtures"
task :flavors_audit do
  flavors = (ENV["FLAVORS"] ||
    "iso itu ogc iec iho bipm cc ribose bsi nist jis gb")
    .split(/[\s,]+/).reject(&:empty?)
  home = Dir.home
  results = {}

  flavors.each do |flavor|
    dir = File.join(home, "src/mn/metanorma-#{flavor}")
    results[flavor] = audit_flavor(flavor, dir)
  end

  results.each do |flavor, lines|
    puts "== #{flavor}"
    Array(lines).each { |l| puts "  #{l}" }
  end
end

def audit_flavor(flavor, dir)
  return ["NO_CHECKOUT #{dir}"] unless File.file?(File.join(dir, "Gemfile"))

  fixtures = (Dir[File.join(dir, "spec/fixtures/**/*presentation*.xml")] +
              Dir[File.join(dir, "**/*presentation*.xml")].reject do |f|
                f.include?("spec/fixtures") || f.include?("node_modules")
              end).uniq.first(2)
  return ["NO_PRESENTATION_FIXTURE"] if fixtures.empty?

  script = flavor_probe_script(flavor, dir, fixtures)
  # The target repo's bundle is its own resolution: make sure it is
  # installed, then run the probe through it.
  gemfile = File.join(dir, "Gemfile")
  # Scrub EVERY BUNDLE*/BUNDLER* var the invoking context leaks —
  # BUNDLE_LOCKFILE/BUNDLER_VERSION silently hijack nested installs.
  scrub = ["env",
           *ENV.keys.select { |k| k.start_with?("BUNDLE") }
             .flat_map { |k| ["-u", k] },
           "-u", "RUBYOPT", "-u", "RUBYLIB",
           "BUNDLE_GEMFILE=#{gemfile}"]
  install_out, install_st = Open3.capture2e(*scrub, "bundle", "install",
                                            chdir: dir)
  unless install_st.success?
    return ["BUNDLE_INSTALL_FAIL",
            *install_out.lines.map(&:strip).reject(&:empty?).last(3)]
  end
  out, _st = Open3.capture2e(*scrub, "bundle", "exec", RbConfig.ruby,
                             "-e", script, chdir: dir)
  out.lines.map(&:strip).reject(&:empty?)
rescue StandardError => e
  ["PROBE_ERROR #{e.class}: #{e.message[0, 100]}"]
end

def flavor_probe_script(flavor, dir, fixtures)
  <<~RUBY
    flavor = #{flavor.inspect}
    dir = #{dir.inspect}
    require "metanorma-core"
    begin
      require "metanorma/\#{flavor}"
    rescue LoadError => e
      puts "LOAD_FAIL \#{e.message[0, 100]}"; exit 2
    end
    require "metanorma/html/generator"
    require "timeout"
    root = nil
    [Metanorma::Core::Flavors].each do |_|
      Metanorma::Core::Flavors.table.reverse_each do |entry|
        next if entry.respond_to?(:taste?) && entry.taste?
        next unless entry.name.to_s == "\#{flavor}"
        mc = entry.model_root_class rescue nil
        root = mc if mc
      end
    end
    begin
      root ||= Object.const_get("Metanorma::#{flavor.capitalize}::Document::Root")
    rescue NameError
      root = nil
    end
    unless root
      puts "NO_ROOT"; exit 3
    end
    #{fixtures.inspect}.each do |fx|
      label = fx.sub("\#{dir}/", "")
      begin
        model = Timeout.timeout(120) { root.from_xml(File.read(fx, encoding: "utf-8")) }
        puts "PARSE_OK \#{label}"
        begin
          html = Timeout.timeout(120) { Metanorma::Html::Generator.generate(model) }
          require "nokogiri"
          page = Nokogiri::HTML(html)
          page.css("header, nav, .header-actions, button, kbd").remove
          p_count = page.css("p").size
          verdict = p_count.positive? ? "CONTENT" : "EMPTY_SHELL"
          puts "HTML_\#{verdict} \#{label} p=\#{p_count}"
        rescue Timeout::Error
          puts "HTML_TIMEOUT \#{label}"
        rescue StandardError => e
          puts "HTML_FAIL \#{label} \#{e.class}: \#{e.message[0, 100]}"
        end
      rescue Timeout::Error
        puts "PARSE_TIMEOUT \#{label}"
      rescue StandardError => e
        puts "PARSE_FAIL \#{label} \#{e.class}: \#{e.message[0, 100]}"
      end
    end
  RUBY
end
