import type { Component } from 'vue'
import ParagraphBlock from './ParagraphBlock.vue'
import AdmonitionBlock from './AdmonitionBlock.vue'
import TableBlock from './TableBlock.vue'
import FigureBlock from './FigureBlock.vue'
import SourcecodeBlock from './SourcecodeBlock.vue'
import NoteBlock from './NoteBlock.vue'
import ExampleBlock from './ExampleBlock.vue'
import ListBlocks from './ListBlocks.vue'
import QuoteBlock from './QuoteBlock.vue'
import ReviewBlock from './ReviewBlock.vue'
import FootnotesBlock from './FootnotesBlock.vue'
import FallbackBlock from './FallbackBlock.vue'

const BLOCK_COMPONENTS: Record<string, Component> = {
  paragraph: ParagraphBlock,
  admonition: AdmonitionBlock,
  table: TableBlock,
  figure: FigureBlock,
  image: FigureBlock,
  sourcecode: SourcecodeBlock,
  note: NoteBlock,
  example: ExampleBlock,
  bullet_list: ListBlocks,
  ordered_list: ListBlocks,
  dl: ListBlocks,
  quote: QuoteBlock,
  review: ReviewBlock,
  footnotes: FootnotesBlock,
  formula: SourcecodeBlock,
  floating_title: ParagraphBlock,
}

export function getBlockComponent(type: string): Component {
  return BLOCK_COMPONENTS[type] ?? FallbackBlock
}
