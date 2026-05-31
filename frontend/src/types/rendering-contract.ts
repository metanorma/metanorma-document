/**
 * Rendering contract between Ruby HtmlRenderer and Vue MirrorRenderer.
 *
 * Single source of truth for the mirror node format.
 * Both renderers must handle every node type listed here.
 *
 * When adding a new block type:
 *   1. Add it to BLOCK_TYPES below
 *   2. Implement render_{type} in Ruby HtmlRenderer
 *   3. Add a Vue block component and register it in blocks/index.ts
 *   4. Update the cross-validation spec
 */

// ── Inline mark types ──────────────────────────────────────────────

export const MARK_TYPES = [
  'emphasis',
  'strong',
  'subscript',
  'superscript',
  'code',
  'underline',
  'strike',
  'smallcap',
  'link',
  'xref',
  'eref',
  'footnote',
  'stem',
  'concept',
  'bcp14',
  'span',
] as const

export type MarkType = (typeof MARK_TYPES)[number]

// ── Section types (rendered by ClauseBlock) ───────────────────────

export const SECTION_TYPES = [
  'clause',
  'annex',
  'content_section',
  'abstract',
  'foreword',
  'introduction',
  'acknowledgements',
  'terms',
  'definitions',
  'references',
  'bibliography',
  'preface',
  'sections',
] as const

export type SectionType = (typeof SECTION_TYPES)[number]

// ── Block type specification ───────────────────────────────────────

export type ChildrenKind = 'inline' | 'block' | 'mixed' | 'none'

export interface BlockTypeSpec {
  /** Mirror node type string */
  nodeType: string
  /** Primary CSS class used by Ruby HtmlRenderer */
  rubyCssClass: string
  /** Expected attrs keys (excluding id which is universal) */
  attrs: string[]
  /** What kind of children this node contains */
  children: ChildrenKind
}

export const BLOCK_TYPES: BlockTypeSpec[] = [
  // ── Prose ──
  {
    nodeType: 'paragraph',
    rubyCssClass: 'mn-paragraph',
    attrs: ['id'],
    children: 'inline',
  },
  {
    nodeType: 'floating_title',
    rubyCssClass: 'mn-floating-title',
    attrs: ['id', 'title', 'level'],
    children: 'none',
  },
  {
    nodeType: 'quote',
    rubyCssClass: 'mn-quote',
    attrs: ['id'],
    children: 'block',
  },
  {
    nodeType: 'review',
    rubyCssClass: 'mn-review',
    attrs: ['id', 'review_type', 'reviewer', 'date'],
    children: 'block',
  },

  // ── Code ──
  {
    nodeType: 'sourcecode',
    rubyCssClass: 'mn-sourcecode',
    attrs: ['id', 'language', 'text', 'title'],
    children: 'none',
  },

  // ── Admonition ──
  {
    nodeType: 'admonition',
    rubyCssClass: 'mn-admonition',
    attrs: ['id', 'type', 'title'],
    children: 'block',
  },
  {
    nodeType: 'note',
    rubyCssClass: 'mn-note',
    attrs: ['id', 'type', 'title'],
    children: 'block',
  },
  {
    nodeType: 'example',
    rubyCssClass: 'mn-example',
    attrs: ['id', 'type', 'title'],
    children: 'block',
  },

  // ── Media ──
  {
    nodeType: 'figure',
    rubyCssClass: 'mn-figure',
    attrs: ['id', 'title'],
    children: 'block',
  },
  {
    nodeType: 'image',
    rubyCssClass: 'mn-image',
    attrs: ['id', 'src', 'alt', 'title'],
    children: 'none',
  },

  // ── Table ──
  {
    nodeType: 'table',
    rubyCssClass: 'mn-table',
    attrs: ['id', 'title'],
    children: 'block',
  },

  // ── Lists ──
  {
    nodeType: 'ordered_list',
    rubyCssClass: 'mn-ordered-list',
    attrs: ['id'],
    children: 'block',
  },
  {
    nodeType: 'bullet_list',
    rubyCssClass: 'mn-bullet-list',
    attrs: ['id'],
    children: 'block',
  },
  {
    nodeType: 'dl',
    rubyCssClass: 'mn-definition-list',
    attrs: ['id'],
    children: 'block',
  },

  // ── Formula ──
  {
    nodeType: 'formula',
    rubyCssClass: 'mn-formula',
    attrs: ['id', 'text'],
    children: 'none',
  },

  // ── Footnotes ──
  {
    nodeType: 'footnotes',
    rubyCssClass: 'mn-footnotes',
    attrs: [],
    children: 'block',
  },
]

// ── Derived lookup maps ────────────────────────────────────────────

/** All block node types handled by the block component registry */
export const BLOCK_NODE_TYPES: Set<string> = new Set(BLOCK_TYPES.map((b) => b.nodeType))

/** All section node types handled by ClauseBlock */
export const SECTION_NODE_TYPES: Set<string> = new Set(SECTION_TYPES)

/** Complete set of all rendered node types */
export const ALL_NODE_TYPES: Set<string> = new Set([
  ...SECTION_TYPES,
  ...BLOCK_TYPES.map((b) => b.nodeType),
  'doc',
  'soft_break',
  'text',
  'footnote_marker',
  'list_item',
  'dt',
  'dd',
  'table_head',
  'table_body',
  'table_row',
  'table_cell',
])
