require "metanorma/document"
require "metanorma/iso_document"
require "metanorma/ogc_document"
require "metanorma/html"

# ISO
iso_xml = File.read("spec/fixtures/iso/is/document-en.presentation.xml")
iso_doc = Metanorma::IsoDocument::Root.from_xml(iso_xml)
iso_output = Metanorma::Html::Generator.generate(iso_doc)
File.write("/tmp/iso_output.html", iso_output)
puts "ISO: #{iso_output.size} chars written to /tmp/iso_output.html"

# OGC
ogc_xml = File.read("spec/fixtures/ogc/00-027/document.presentation.xml")
ogc_doc = Metanorma::OgcDocument::Root.from_xml(ogc_xml)
ogc_output = Metanorma::Html::Generator.generate(ogc_doc)
File.write("/tmp/ogc_output.html", ogc_output)
puts "OGC: #{ogc_output.size} chars written to /tmp/ogc_output.html"
