import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useDocumentStore } from '../documentStore'

describe('useDocumentStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  describe('defaults', () => {
    it('has null document before loading', () => {
      const store = useDocumentStore()
      expect(store.mirrorDocument).toBeNull()
      expect(store.documentMeta).toBeNull()
      expect(store.title).toBe('Metanorma Document')
      expect(store.flavor).toBe('')
      expect(store.sections).toEqual([])
      expect(store.numbering).toEqual({})
    })
  })

  describe('processMetanormaData', () => {
    it('processes a doc with attrs', () => {
      const store = useDocumentStore()
      store.processMetanormaData({
        type: 'doc',
        attrs: { title: 'ISO 9001', flavor: 'iso' },
        content: [
          {
            type: 'clause',
            attrs: { id: 'scope', title: 'Scope', number: '1' },
            content: [],
          },
          {
            type: 'clause',
            attrs: { id: 'defs', title: 'Definitions', number: '3' },
            content: [],
          },
        ],
      })

      expect(store.mirrorDocument).not.toBeNull()
      expect(store.title).toBe('ISO 9001')
      expect(store.flavor).toBe('iso')
      expect(store.sections).toHaveLength(2)
      expect(store.sections[0]).toEqual({
        id: 'scope',
        title: 'Scope',
        type: 'clause',
        children: [],
      })
    })

    it('processes nested sections for TOC', () => {
      const store = useDocumentStore()
      store.processMetanormaData({
        type: 'doc',
        attrs: { title: 'Test' },
        content: [
          {
            type: 'clause',
            attrs: { id: 's1', title: 'Section 1' },
            content: [
              {
                type: 'clause',
                attrs: { id: 's1-1', title: 'Subsection 1.1' },
                content: [],
              },
            ],
          },
        ],
      })

      expect(store.sections).toHaveLength(1)
      expect(store.sections[0].children).toHaveLength(1)
      expect(store.sections[0].children[0].id).toBe('s1-1')
    })

    it('ignores non-section blocks in TOC extraction', () => {
      const store = useDocumentStore()
      store.processMetanormaData({
        type: 'doc',
        content: [
          { type: 'paragraph', content: [{ type: 'text', text: 'Hello' }] },
          { type: 'clause', attrs: { id: 'scope', title: 'Scope' }, content: [] },
          { type: 'bullet_list', content: [] },
        ],
      })

      expect(store.sections).toHaveLength(1)
      expect(store.sections[0].type).toBe('clause')
    })

    it('uses toc data when provided', () => {
      const store = useDocumentStore()
      store.processMetanormaData({
        type: 'doc',
        attrs: { title: 'Has TOC' },
        content: [],
        toc: {
          sections: [
            { id: 's1', title: 'Section 1', type: 'clause', children: [] },
          ],
          numbering: { s1: '1' },
        },
      })

      expect(store.sections).toHaveLength(1)
      expect(store.numbering).toEqual({ s1: '1' })
    })

    it('uses meta fields when present', () => {
      const store = useDocumentStore()
      store.processMetanormaData({
        type: 'doc',
        attrs: {},
        content: [],
        meta: { title: 'Meta Title', flavor: 'iec' },
      })

      expect(store.title).toBe('Meta Title')
      expect(store.flavor).toBe('iec')
    })
  })

  describe('getNumbering', () => {
    it('returns numbering for known id', () => {
      const store = useDocumentStore()
      store.processMetanormaData({
        type: 'doc',
        content: [],
        toc: { sections: [], numbering: { scope: '1' } },
      })

      expect(store.getNumbering('scope')).toBe('1')
    })

    it('returns empty string for unknown id', () => {
      const store = useDocumentStore()
      expect(store.getNumbering('unknown')).toBe('')
    })
  })
})
