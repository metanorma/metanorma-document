import { describe, it, expect } from 'vitest'
import { SECTION_TYPES, isSectionType, SECTION_META, getTypeLabel, getTypeBadgeClass } from '../typeMetadata'
import { SECTION_TYPES as CONTRACT_SECTIONS } from '../../types/rendering-contract'

describe('isSectionType', () => {
  it('returns true for section-like types', () => {
    const types = ['clause', 'annex', 'content_section', 'abstract', 'foreword',
      'introduction', 'acknowledgements', 'terms', 'definitions',
      'references', 'bibliography', 'preface', 'sections']

    for (const t of types) {
      expect(isSectionType(t)).toBe(true)
    }
  })

  it('returns false for non-section types', () => {
    expect(isSectionType('paragraph')).toBe(false)
    expect(isSectionType('sourcecode')).toBe(false)
    expect(isSectionType('figure')).toBe(false)
    expect(isSectionType('table')).toBe(false)
    expect(isSectionType('admonition')).toBe(false)
    expect(isSectionType('bullet_list')).toBe(false)
  })

  it('matches rendering contract SECTION_TYPES', () => {
    for (const t of CONTRACT_SECTIONS) {
      expect(isSectionType(t), `contract type "${t}" not in UI SECTION_TYPES`).toBe(true)
    }
  })
})

describe('SECTION_META', () => {
  it('defines metadata for all section types', () => {
    for (const type of SECTION_TYPES) {
      expect(SECTION_META[type], `${type} should have SECTION_META entry`).toBeDefined()
    }
  })

  it('all entries have tag and headingTag', () => {
    for (const [type, meta] of Object.entries(SECTION_META)) {
      expect(meta.tag, `${type} should have tag`).toMatch(/^section$/)
      expect(meta.headingTag, `${type} should have headingTag`).toBeTruthy()
      expect(meta.headingClass, `${type} should have headingClass`).toBeTruthy()
    }
  })

  it('clause uses h2', () => {
    expect(SECTION_META.clause.headingTag).toBe('h2')
  })

  it('annex uses h2', () => {
    expect(SECTION_META.annex.headingTag).toBe('h2')
  })

  it('preface uses h1', () => {
    expect(SECTION_META.preface.headingTag).toBe('h1')
  })

  it('sections uses h1', () => {
    expect(SECTION_META.sections.headingTag).toBe('h1')
  })
})

describe('getTypeLabel', () => {
  it('returns non-empty for major types', () => {
    expect(getTypeLabel('clause')).toBeTruthy()
    expect(getTypeLabel('annex')).toBeTruthy()
    expect(getTypeLabel('terms')).toBeTruthy()
    expect(getTypeLabel('references')).toBeTruthy()
  })

  it('returns empty for unknown', () => {
    expect(getTypeLabel('foobar')).toBe('')
  })
})

describe('getTypeBadgeClass', () => {
  it('returns badge-neutral for unknown', () => {
    expect(getTypeBadgeClass('foobar')).toBe('badge-neutral')
  })

  it('returns different classes for different types', () => {
    const classes = new Set([
      getTypeBadgeClass('clause'),
      getTypeBadgeClass('annex'),
      getTypeBadgeClass('terms'),
    ])
    expect(classes.size).toBeGreaterThan(1)
  })

  it('returns badge-accent for clause', () => {
    expect(getTypeBadgeClass('clause')).toBe('badge-accent')
  })

  it('returns badge-info for terms', () => {
    expect(getTypeBadgeClass('terms')).toBe('badge-info')
  })

  it('returns badge-reference for references', () => {
    expect(getTypeBadgeClass('references')).toBe('badge-reference')
  })
})
