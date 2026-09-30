# frozen_string_literal: true

module Metanorma
  module Document
    module Components
      # The semantic vocabulary namespace (semantic__* elements under
      # metanorma-extension/metanorma/source): the machine-readable
      # layer flavors embed alongside the presentation tree. Element
      # names are dynamic per flavor and document, so one recursive
      # model serves the whole namespace; element_order preserves the
      # mixed-content sequence for ordered rendering.
      module Semantic
        class Node < Lutaml::Model::Serializable
          CHILD_TAGS = %w[
        semantic__AmountOfSubstance semantic__Dimension semantic__DimensionSet semantic__ElectricCurrent semantic__EnumeratedRootUnit semantic__Length
        semantic__LuminousIntensity semantic__Mass semantic__PlaneAngle semantic__Prefix semantic__PrefixName semantic__PrefixSet
        semantic__PrefixSymbol semantic__Quantity semantic__QuantityName semantic__QuantitySet semantic__RootUnits semantic__ThermodynamicTemperature
        semantic__Time semantic__Unit semantic__UnitName semantic__UnitSet semantic__UnitSymbol semantic__UnitSystem
        semantic__UnitsML semantic__abbreviation semantic__abbreviation-type semantic__abstract semantic__acknowledgements semantic__add
        semantic__address semantic__admitted semantic__admonition semantic__affiliation semantic__agency semantic__annex
        semantic__annexid semantic__approvalgroup semantic__asciimath semantic__author semantic__bibdata semantic__bibitem
        semantic__bibliography semantic__boilerplate semantic__bookmark semantic__br semantic__bureau semantic__circle
        semantic__city semantic__clause semantic__clipPath semantic__code semantic__col semantic__colgroup
        semantic__colophon semantic__color-backpage-background semantic__color-list-label semantic__color-secondary-shade-1 semantic__color-secondary-shade-2 semantic__color-secondary-shade-3
        semantic__color-secondary-shade-4 semantic__committee semantic__completename semantic__concept semantic__contributor semantic__copyright
        semantic__copyright-statement semantic__country semantic__credentials semantic__date semantic__dd semantic__definition
        semantic__definitions semantic__defs semantic__del semantic__deprecates semantic__description semantic__dl
        semantic__docidentifier semantic__docnumber semantic__doctype semantic__domain semantic__dt semantic__edition
        semantic__editorialgroup semantic__em semantic__email semantic__eref semantic__example semantic__executivesummary
        semantic__expression semantic__ext semantic__feedback-statement semantic__fetched semantic__figure semantic__fn
        semantic__forename semantic__foreword semantic__formatted-initials semantic__formattedAddress semantic__formattedref semantic__formula
        semantic__from semantic__g semantic__group semantic__ics semantic__image semantic__index
        semantic__index-xref semantic__indexsect semantic__introduction semantic__ip-notice-received semantic__iteration semantic__keyword
        semantic__language semantic__latexmath semantic__legal-statement semantic__li semantic__license-statement semantic__line
        semantic__link semantic__locality semantic__localityStack semantic__location semantic__math semantic__meeting
        semantic__meeting-date semantic__meeting-place semantic__metanorma-extension semantic__mfenced semantic__mfrac semantic__mi
        semantic__mn semantic__mo semantic__modification semantic__mover semantic__mrow semantic__msqrt
        semantic__mstyle semantic__msub semantic__msubsup semantic__msup semantic__mtable semantic__mtd
        semantic__mtext semantic__mtr semantic__munder semantic__munderover semantic__name semantic__note
        semantic__number semantic__ol semantic__on semantic__organization semantic__origin semantic__owner
        semantic__p semantic__pagebreak semantic__path semantic__person semantic__phone semantic__place
        semantic__polygon semantic__polyline semantic__preface semantic__preferred semantic__presentation-metadata semantic__primary
        semantic__project-number semantic__quote semantic__rect semantic__referenceFrom semantic__referenceTo semantic__references
        semantic__refterm semantic__relation semantic__renderterm semantic__revision-date semantic__role semantic__script
        semantic__secondary semantic__sections semantic__semantic-metadata semantic__series semantic__smallcap semantic__source
        semantic__sourcecode semantic__span semantic__stage semantic__stagename semantic__state semantic__status
        semantic__stem semantic__strike semantic__strong semantic__structuredidentifier semantic__style semantic__sub
        semantic__substage semantic__sup semantic__suppl-type semantic__suppl-version semantic__surname semantic__svg
        semantic__table semantic__target semantic__tbody semantic__td semantic__term semantic__termdocsource
        semantic__termexample semantic__termnote semantic__terms semantic__termsource semantic__tertiary semantic__text
        semantic__th semantic__thead semantic__title semantic__to semantic__tr semantic__tt
        semantic__ul semantic__underline semantic__upi semantic__uri semantic__value semantic__variant
        semantic__verbal-definition semantic__version semantic__version-history semantic__xref
          ].freeze

          ROOT_TAGS = %w[
                        semantic__bipm-standard semantic__bsi-standard semantic__itu-standard semantic__jis-standard semantic__nist-standard
          ].freeze

          # sem_-prefixed names avoid collisions with the tag-derived
          # child collections (semantic__target etc. exist as elements).
          XML_ATTRIBUTES = {
            "id" => :id, "target" => :sem_target, "citeas" => :citeas,
            "bibitemid" => :bibitemid, "type" => :type_attr,
            "language" => :sem_language, "script" => :sem_script,
            "format" => :format, "alt" => :alt, "style" => :sem_style,
            "display" => :display, "scope" => :scope, "role" => :sem_role,
            "label" => :label, "number" => :sem_number, "value" => :sem_value,
            "url" => :url, "href" => :href, "from" => :sem_from,
            "prefix" => :prefix, "hidden" => :hidden, "obligation" => :obligation,
          }.freeze

          def self.attr_for(tag)
            tag.sub("semantic__", "").tr("-", "_").to_sym
          end

          # Precomputed: the xml mapping block evaluates in the mapping
          # object's context, so class helpers are out of reach there.
          TAG_ATTRS = (CHILD_TAGS + ROOT_TAGS)
                      .map { |tag| [tag, attr_for(tag)] }.freeze

          TAG_ATTRS.each do |_tag, attr|
            attribute attr,
                      "Metanorma::Document::Components::Semantic::Node",
                      collection: true
          end

          XML_ATTRIBUTES.each_value { |attr| attribute attr, :string }

          xml do
            TAG_ATTRS.each do |tag, attr|
              map_element tag, to: attr
            end
            XML_ATTRIBUTES.each do |xml_name, attr|
              map_attribute xml_name, to: attr
            end
          end
        end
      end
    end
  end
end
