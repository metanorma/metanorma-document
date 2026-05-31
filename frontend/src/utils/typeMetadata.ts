/**
 * Canonical metadata for Metanorma section/block types.
 */

export const SECTION_TYPES = new Set([
  'clause', 'annex', 'content_section', 'abstract', 'foreword',
  'introduction', 'acknowledgements', 'terms', 'definitions',
  'references', 'bibliography', 'preface', 'sections',
])

export function isSectionType(type: string): boolean {
  return SECTION_TYPES.has(type)
}

export interface SectionMeta {
  tag: 'section' | 'article'
  headingTag: string
  headingClass: string
  noAnchor?: boolean
  noNumbering?: boolean
}

export const SECTION_META: Record<string, SectionMeta> = {
  clause: {
    tag: 'section',
    headingTag: 'h2',
    headingClass: 'text-xl font-semibold mb-3',
  },
  annex: {
    tag: 'section',
    headingTag: 'h2',
    headingClass: 'text-xl font-semibold mb-3',
  },
  content_section: {
    tag: 'section',
    headingTag: 'h2',
    headingClass: 'text-xl font-semibold mb-3',
  },
  abstract: {
    tag: 'section',
    headingTag: 'h2',
    headingClass: 'text-lg font-semibold mb-3 italic',
  },
  foreword: {
    tag: 'section',
    headingTag: 'h2',
    headingClass: 'text-xl font-semibold mb-3',
  },
  introduction: {
    tag: 'section',
    headingTag: 'h2',
    headingClass: 'text-xl font-semibold mb-3',
  },
  acknowledgements: {
    tag: 'section',
    headingTag: 'h2',
    headingClass: 'text-xl font-semibold mb-3',
  },
  terms: {
    tag: 'section',
    headingTag: 'h2',
    headingClass: 'text-xl font-semibold mb-3',
  },
  definitions: {
    tag: 'section',
    headingTag: 'h2',
    headingClass: 'text-xl font-semibold mb-3',
  },
  references: {
    tag: 'section',
    headingTag: 'h2',
    headingClass: 'text-xl font-semibold mb-3',
  },
  bibliography: {
    tag: 'section',
    headingTag: 'h2',
    headingClass: 'text-xl font-semibold mb-3',
  },
  preface: {
    tag: 'section',
    headingTag: 'h1',
    headingClass: 'text-2xl font-bold mb-4',
  },
  sections: {
    tag: 'section',
    headingTag: 'h1',
    headingClass: 'text-2xl font-bold mb-4',
  },
}

export function getTypeBadgeClass(type: string): string {
  switch (type) {
    case 'clause': return 'badge-accent'
    case 'annex': return 'badge-warning'
    case 'terms': return 'badge-info'
    case 'definitions': return 'badge-info'
    case 'references': return 'badge-reference'
    case 'bibliography': return 'badge-reference'
    case 'abstract': return 'badge-neutral'
    case 'foreword': return 'badge-neutral'
    case 'introduction': return 'badge-neutral'
    case 'acknowledgements': return 'badge-neutral'
    default: return 'badge-neutral'
  }
}

export function getTypeLabel(type: string): string {
  switch (type) {
    case 'clause': return '§'
    case 'annex': return 'Annex'
    case 'terms': return 'Terms'
    case 'definitions': return 'Def'
    case 'references': return 'Ref'
    case 'bibliography': return 'Bib'
    case 'abstract': return 'Abs'
    case 'foreword': return 'Fwd'
    case 'introduction': return 'Intro'
    case 'acknowledgements': return 'Ack'
    default: return ''
  }
}
