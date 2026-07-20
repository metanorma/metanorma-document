# frozen_string_literal: true

module Metanorma
  module Html
    module Renderers
      # Builds the reverse lookup `{ xml_element_name => attribute_name }`
      # from a node's xml mapping. Shared between walkers that iterate
      # element_order: InlineRenderer#walk_ordered (renders in document
      # order) and BaseRenderer#extract_plain_text (extracts text).
      #
      # Both walkers previously reimplemented this hash construction
      # inline; the construction is the genuinely-shared traversal
      # concern. Per-element handling (recursion, span emission, tab/br
      # spacing) differs and stays in each walker.
      module ElementOrderTraversal
        module_function

        # The map depends only on the model class's xml mapping, which is
        # immutable after class definition — cache one map per mapping
        # object instead of rebuilding it for every rendered node.
        @cache = {}.compare_by_identity

        def element_to_attr_map(xml_mapping)
          @cache[xml_mapping] ||= build_map(xml_mapping)
        end

        # Test/benchmark hook: drop all memoized maps.
        def reset_cache!
          @cache.clear
        end

        # Returns `{ xml_element_name => attr_name }` including both
        # symbol and string keys for each mapped element, so callers
        # can look up by either el.name form.
        def build_map(xml_mapping)
          {}.tap do |map|
            xml_mapping.mapping_elements_hash.each_value do |rule_or_array|
              Array(rule_or_array).each do |rule|
                map[rule.name] = rule.to
                map[rule.name.to_s] = rule.to if rule.name.is_a?(Symbol)
              end
            end
          end
        end
      end
    end
  end
end
