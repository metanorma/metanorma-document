# frozen_string_literal: true

module Metanorma
  module Html
    module Component
      class IndexTermCollector
        def initialize
          @terms = []
        end

        def add(primary:, secondary: nil, tertiary: nil,
                see: nil, see_also: nil, target_id: nil, target_text: nil)
          @terms << IndexTerm.new(
            primary: primary,
            secondary: secondary,
            tertiary: tertiary,
            see: see,
            see_also: see_also,
            target_id: target_id,
            target_text: target_text
          )
        end

        def empty?
          @terms.empty?
        end

        def sorted_groups
          grouped = @terms
            .group_by { |t| t.primary[0].upcase }
            .sort_by { |letter, _| letter }

          grouped.map do |letter, terms|
            IndexLetterGroup.new(letter: letter, entries: merge_entries(terms))
          end
        end

        private

        def merge_entries(terms)
          primary_map = {}
          terms.each do |term|
            key = term.primary.downcase
            primary_map[key] ||= IndexEntry.new(term: term.primary)
            entry = primary_map[key]
            entry.add_locator(term.target_id, term.target_text)
            entry.see ||= term.see
            entry.add_see_also(term.see_also) if term.see_also

            if term.secondary
              sec = entry.find_or_add_child(term.secondary)
              sec.add_locator(term.target_id, term.target_text)

              if term.tertiary
                ter = sec.find_or_add_child(term.tertiary)
                ter.add_locator(term.target_id, term.target_text)
              end
            end
          end

          primary_map.values.sort_by { |e| e.term.downcase }
        end
      end

      IndexTerm = Struct.new(:primary, :secondary, :tertiary,
                             :see, :see_also, :target_id, :target_text,
                             keyword_init: true)

      IndexEntry = Struct.new(:term, :locators, :see, :see_also_entries, :children,
                               keyword_init: true) do
        def initialize(*)
          super
          self.locators ||= []
          self.see_also_entries ||= []
          self.children ||= []
        end

        def add_locator(id, text)
          locators << IndexLocator.new(id: id, text: text) if id && !locators.any? { |l| l.id == id }
        end

        def add_see_also(term)
          see_also_entries << term if term
        end

        def find_or_add_child(term_name)
          existing = children.find { |c| c.term.downcase == term_name.downcase }
          existing || begin
            child = IndexEntry.new(term: term_name)
            children << child
            child
          end
        end
      end

      IndexLocator = Struct.new(:id, :text, keyword_init: true)
      IndexLetterGroup = Struct.new(:letter, :entries, keyword_init: true)
    end
  end
end
