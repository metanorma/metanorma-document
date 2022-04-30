# frozen_string_literal: true

module Metanorma; module Document; module IsoDocument
  # Substage-level code in the International Harmonized Stage Codes.
  # These codes are used by ISO and IEC to indicate development stage.
  #
  # NOTE: See https://www.iso.org/stage-codes.html for the full list.
  class IsoDocumentSubstageCodes < Core::Node::Enum
    CODE_00 = new("00")

    CODE_20 = new("20")

    CODE_60 = new("60")

    CODE_90 = new("90")

    CODE_92 = new("92")

    CODE_93 = new("93")

    CODE_98 = new("98")

    CODE_99 = new("99")
  end
end; end; end
