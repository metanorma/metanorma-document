# frozen_string_literal: true

desc "Diff the grammar-coverage vocabulary against standoc-models"
task :grammar_coverage do
  require_relative "../lib/metanorma/document/grammar_vocabulary"

  dir = ENV["STANDOC_MODELS"] ||
    File.expand_path("~/src/mn/standoc-models/grammars")
  abort <<~MSG unless File.directory?(dir)
    standoc-models grammars not found at #{dir}
    Clone metanorma/standoc-models or point STANDOC_MODELS at its grammars/ dir.
  MSG

  fresh = Metanorma::Document::GrammarVocabulary.scan(dir)
  spec = {
    semantic: Metanorma::Document::GrammarVocabulary::SEMANTIC_ELEMENTS,
    presentation: Metanorma::Document::GrammarVocabulary::PRESENTATION_ELEMENTS,
  }

  %i[semantic presentation].each do |kind|
    added = fresh[kind] - spec[kind]
    stale = spec[kind] - fresh[kind]
    puts "== #{kind}: grammar #{fresh[kind].size} vs spec #{spec[kind].size}"
    puts "  new in grammar (classify: map, delegate, or gap): #{added.join(' ')}" unless added.empty?
    puts "  gone from grammar (stale spec entries): #{stale.join(' ')}" unless stale.empty?
    puts "  in sync" if added.empty? && stale.empty?
  end
end
