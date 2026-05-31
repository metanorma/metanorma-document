import { describe, it, expect } from 'vitest'
import {
  MARK_TYPES,
  SECTION_TYPES,
  BLOCK_TYPES,
  BLOCK_NODE_TYPES,
  SECTION_NODE_TYPES,
  ALL_NODE_TYPES,
} from '../rendering-contract'
import { getBlockComponent } from '../../components/blocks'
import { SECTION_TYPES as UI_SECTION_TYPES, SECTION_META } from '../../utils/typeMetadata'
import ParagraphBlock from '../../components/blocks/ParagraphBlock.vue'
import AdmonitionBlock from '../../components/blocks/AdmonitionBlock.vue'
import TableBlock from '../../components/blocks/TableBlock.vue'
import FigureBlock from '../../components/blocks/FigureBlock.vue'
import SourcecodeBlock from '../../components/blocks/SourcecodeBlock.vue'
import NoteBlock from '../../components/blocks/NoteBlock.vue'
import ExampleBlock from '../../components/blocks/ExampleBlock.vue'
import ListBlocks from '../../components/blocks/ListBlocks.vue'
import QuoteBlock from '../../components/blocks/QuoteBlock.vue'
import ReviewBlock from '../../components/blocks/ReviewBlock.vue'
import FootnotesBlock from '../../components/blocks/FootnotesBlock.vue'
import FallbackBlock from '../../components/blocks/FallbackBlock.vue'

describe('rendering-contract', () => {
  describe('MARK_TYPES', () => {
    it('covers all marks produced by Ruby Mirror::Mark subclasses', () => {
      const expected = [
        'emphasis', 'strong', 'subscript', 'superscript',
        'code', 'underline', 'strike', 'smallcap',
        'link', 'xref', 'eref', 'footnote',
        'stem', 'concept', 'bcp14', 'span',
      ]
      for (const mark of expected) {
        expect(MARK_TYPES).toContain(mark)
      }
    })

    it('has no duplicates', () => {
      expect(MARK_TYPES.length).toBe(new Set(MARK_TYPES).size)
    })
  })

  describe('SECTION_TYPES', () => {
    it('matches UI typeMetadata SECTION_TYPES set', () => {
      for (const t of SECTION_TYPES) {
        expect(UI_SECTION_TYPES.has(t), `contract section type "${t}" missing from UI SECTION_TYPES`).toBe(true)
      }
    })

    it('has metadata for every section type', () => {
      for (const t of SECTION_TYPES) {
        expect(SECTION_META[t], `SECTION_META missing for "${t}"`).toBeDefined()
      }
    })

    it('every section type has tag and headingTag', () => {
      for (const t of SECTION_TYPES) {
        const meta = SECTION_META[t]
        expect(meta.tag, `${t} should have tag`).toMatch(/^(section|article)$/)
        expect(meta.headingTag, `${t} should have headingTag`).toBeTruthy()
      }
    })
  })

  describe('BLOCK_TYPES', () => {
    it('every block type has a registered Vue component', () => {
      for (const spec of BLOCK_TYPES) {
        const component = getBlockComponent(spec.nodeType)
        expect(component).not.toBe(FallbackBlock)
        expect(component, `block type "${spec.nodeType}" should have a component`).toBeDefined()
      }
    })

    it('every block type spec has required fields', () => {
      for (const spec of BLOCK_TYPES) {
        expect(spec.nodeType, 'nodeType should be set').toBeTruthy()
        expect(spec.rubyCssClass, `${spec.nodeType} should have rubyCssClass`).toBeTruthy()
        expect(spec.children, `${spec.nodeType} should define children kind`).toMatch(/^(inline|block|mixed|none)$/)
        expect(Array.isArray(spec.attrs), `${spec.nodeType} attrs should be array`).toBe(true)
      }
    })
  })

  describe('BLOCK_NODE_TYPES set', () => {
    it('contains all node types from BLOCK_TYPES', () => {
      for (const spec of BLOCK_TYPES) {
        expect(BLOCK_NODE_TYPES.has(spec.nodeType)).toBe(true)
      }
    })

    it('does not contain section types', () => {
      for (const t of SECTION_TYPES) {
        expect(BLOCK_NODE_TYPES.has(t), `section type "${t}" should not be in BLOCK_NODE_TYPES`).toBe(false)
      }
    })
  })

  describe('SECTION_NODE_TYPES set', () => {
    it('contains all section types', () => {
      for (const t of SECTION_TYPES) {
        expect(SECTION_NODE_TYPES.has(t)).toBe(true)
      }
    })
  })

  describe('ALL_NODE_TYPES set', () => {
    it('includes structural node types', () => {
      expect(ALL_NODE_TYPES.has('doc')).toBe(true)
      expect(ALL_NODE_TYPES.has('text')).toBe(true)
      expect(ALL_NODE_TYPES.has('soft_break')).toBe(true)
      expect(ALL_NODE_TYPES.has('footnote_marker')).toBe(true)
    })

    it('includes table structural types', () => {
      expect(ALL_NODE_TYPES.has('table_head')).toBe(true)
      expect(ALL_NODE_TYPES.has('table_body')).toBe(true)
      expect(ALL_NODE_TYPES.has('table_row')).toBe(true)
      expect(ALL_NODE_TYPES.has('table_cell')).toBe(true)
    })

    it('includes list structural types', () => {
      expect(ALL_NODE_TYPES.has('list_item')).toBe(true)
      expect(ALL_NODE_TYPES.has('dt')).toBe(true)
      expect(ALL_NODE_TYPES.has('dd')).toBe(true)
    })

    it('covers all section and block types', () => {
      for (const t of SECTION_TYPES) {
        expect(ALL_NODE_TYPES.has(t), `missing section type ${t}`).toBe(true)
      }
      for (const spec of BLOCK_TYPES) {
        expect(ALL_NODE_TYPES.has(spec.nodeType), `missing block type ${spec.nodeType}`).toBe(true)
      }
    })
  })

  describe('block component mapping coverage', () => {
    const expectedMappings: Record<string, any> = {
      paragraph: ParagraphBlock,
      admonition: AdmonitionBlock,
      note: NoteBlock,
      example: ExampleBlock,
      table: TableBlock,
      figure: FigureBlock,
      image: FigureBlock,
      sourcecode: SourcecodeBlock,
      formula: SourcecodeBlock,
      bullet_list: ListBlocks,
      ordered_list: ListBlocks,
      dl: ListBlocks,
      quote: QuoteBlock,
      review: ReviewBlock,
      footnotes: FootnotesBlock,
      floating_title: ParagraphBlock,
    }

    for (const [type, expected] of Object.entries(expectedMappings)) {
      it(`maps "${type}" to ${expected.__name || expected.name}`, () => {
        expect(getBlockComponent(type)).toBe(expected)
      })
    }

    it('returns FallbackBlock for unknown types', () => {
      expect(getBlockComponent('unknown_block')).toBe(FallbackBlock)
    })

    it('returns FallbackBlock for empty string', () => {
      expect(getBlockComponent('')).toBe(FallbackBlock)
    })
  })
})
