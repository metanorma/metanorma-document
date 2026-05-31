import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useDocumentStore } from '../documentStore'
import fixture from '@test/fixtures/iso-document.json'

describe('useDocumentStore with real mirror data', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  describe('processMetanormaData with fixture', () => {
    it('sets mirrorDocument from fixture data', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      expect(store.mirrorDocument).not.toBeNull()
      expect(store.mirrorDocument?.type).toBe('doc')
      expect(store.mirrorDocument?.content).toBeDefined()
      expect(store.mirrorDocument!.content!.length).toBeGreaterThan(0)
    })

    it('extracts TOC from toc.sections', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      expect(store.sections.length).toBe(5)
      expect(store.sections[0].id).toBe('foreword')
      expect(store.sections[0].title).toBe('Foreword')
      expect(store.sections[0].type).toBe('foreword')
    })

    it('extracts nested TOC children', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const terms = store.sections.find(s => s.id === 'terms')
      expect(terms).toBeDefined()
      expect(terms!.children.length).toBe(1)
      expect(terms!.children[0].id).toBe('term-rice')
      expect(terms!.children[0].title).toBe('rice')
    })

    it('extracts numbering from toc', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      expect(store.getNumbering('scope')).toBe('1')
      expect(store.getNumbering('normrefs')).toBe('2')
      expect(store.getNumbering('terms')).toBe('3')
      expect(store.getNumbering('term-rice')).toBe('3.1')
      expect(store.getNumbering('test-methods')).toBe('4')
    })

    it('extracts title from meta', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      expect(store.title).toBe('ISO 17301-1:2016 — Cereals and pulses')
    })

    it('extracts flavor from meta', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      expect(store.flavor).toBe('iso')
    })

    it('extracts docType from meta', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      expect(store.docType).toBe('international-standard')
    })

    it('returns empty numbering for unknown id', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      expect(store.getNumbering('nonexistent')).toBe('')
    })

    it('extracts schema version', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      expect(store.documentMeta?.schemaVersion).toBe('v2.1.5')
    })
  })

  describe('document content structure validation', () => {
    it('contains all expected top-level sections', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      const types = content.map(n => n.type)
      expect(types).toContain('foreword')
      expect(types).toContain('clause')
      expect(types).toContain('references')
      expect(types).toContain('terms')
      expect(types).toContain('footnotes')
    })

    it('clause sections have attrs with id and title', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      const clause = content.find(n => n.type === 'clause' && (n as any).attrs?.id === 'scope')
      expect(clause).toBeDefined()
      expect((clause as any).attrs.title).toBe('Scope')
    })

    it('paragraphs contain text nodes with marks', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      // Find scope clause, first paragraph
      const scope = content.find(n => (n as any).attrs?.id === 'scope') as any
      expect(scope).toBeDefined()
      const para = scope.content.find((n: any) => n.type === 'paragraph')
      expect(para).toBeDefined()
      const strongNode = para.content.find((n: any) => n.marks?.some((m: any) => m.type === 'strong'))
      expect(strongNode).toBeDefined()
      expect(strongNode.text).toBe('the test methods')
    })

    it('contains bullet lists with list_items', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      const scope = content.find(n => (n as any).attrs?.id === 'scope') as any
      const list = scope.content.find((n: any) => n.type === 'bullet_list')
      expect(list).toBeDefined()
      expect(list.content.length).toBe(3)
      expect(list.content[0].type).toBe('list_item')
    })

    it('contains tables with head and body', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      const testMethods = content.find(n => (n as any).attrs?.id === 'test-methods') as any
      const table = testMethods.content.find((n: any) => n.type === 'table')
      expect(table).toBeDefined()
      expect(table.content.some((n: any) => n.type === 'table_head')).toBe(true)
      expect(table.content.some((n: any) => n.type === 'table_body')).toBe(true)
    })

    it('contains admonition blocks', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      const testMethods = content.find(n => (n as any).attrs?.id === 'test-methods') as any
      const admonition = testMethods.content.find((n: any) => n.type === 'admonition')
      expect(admonition).toBeDefined()
      expect(admonition.attrs.type).toBe('warning')
    })

    it('contains sourcecode with language', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      const testMethods = content.find(n => (n as any).attrs?.id === 'test-methods') as any
      const code = testMethods.content.find((n: any) => n.type === 'sourcecode')
      expect(code).toBeDefined()
      expect(code.attrs.language).toBe('python')
      expect(code.attrs.text).toContain('moisture_content')
    })

    it('contains figure with image', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      const testMethods = content.find(n => (n as any).attrs?.id === 'test-methods') as any
      const figure = testMethods.content.find((n: any) => n.type === 'figure')
      expect(figure).toBeDefined()
      expect(figure.attrs.title).toContain('Grain structure')
      const image = figure.content.find((n: any) => n.type === 'image')
      expect(image).toBeDefined()
      expect(image.attrs.src).toBe('grain.png')
    })

    it('contains ordered list', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      const testMethods = content.find(n => (n as any).attrs?.id === 'test-methods') as any
      const ol = testMethods.content.find((n: any) => n.type === 'ordered_list')
      expect(ol).toBeDefined()
      expect(ol.content.length).toBe(3)
    })

    it('contains quote block', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      const testMethods = content.find(n => (n as any).attrs?.id === 'test-methods') as any
      const quote = testMethods.content.find((n: any) => n.type === 'quote')
      expect(quote).toBeDefined()
    })

    it('contains formula block', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      const testMethods = content.find(n => (n as any).attrs?.id === 'test-methods') as any
      const formula = testMethods.content.find((n: any) => n.type === 'formula')
      expect(formula).toBeDefined()
      expect(formula.attrs.text).toContain('m =')
    })

    it('contains nested clause (term)', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      const terms = content.find(n => (n as any).attrs?.id === 'terms') as any
      const nestedClause = terms.content.find((n: any) => n.type === 'clause')
      expect(nestedClause).toBeDefined()
      expect(nestedClause.attrs.id).toBe('term-rice')
      // Should contain example and note children
      const childTypes = nestedClause.content.map((n: any) => n.type)
      expect(childTypes).toContain('example')
      expect(childTypes).toContain('note')
    })

    it('contains footnotes section', () => {
      const store = useDocumentStore()
      store.processMetanormaData(fixture)
      const content = store.mirrorDocument!.content!
      const footnotes = content.find(n => n.type === 'footnotes')
      expect(footnotes).toBeDefined()
    })
  })

  describe('fallback behavior (no toc.sections)', () => {
    it('extracts TOC from content when toc.sections absent', () => {
      const store = useDocumentStore()
      const data = {
        type: 'doc',
        content: [
          { type: 'clause', attrs: { id: 's1', title: 'Scope' }, content: [] },
          { type: 'paragraph', content: [{ type: 'text', text: 'hello' }] },
          { type: 'terms', attrs: { id: 't1', title: 'Terms' }, content: [] },
        ],
      }
      store.processMetanormaData(data)
      expect(store.sections.length).toBe(2)
      expect(store.sections[0].id).toBe('s1')
      expect(store.sections[1].id).toBe('t1')
    })

    it('extracts title from meta fallback', () => {
      const store = useDocumentStore()
      const data = {
        type: 'doc',
        meta: { title: 'From Meta' },
        attrs: { title: 'From Attrs' },
        content: [],
      }
      store.processMetanormaData(data)
      expect(store.title).toBe('From Meta')
    })

    it('falls back to attrs title', () => {
      const store = useDocumentStore()
      const data = {
        type: 'doc',
        attrs: { title: 'From Attrs' },
        content: [],
      }
      store.processMetanormaData(data)
      expect(store.title).toBe('From Attrs')
    })

    it('uses default title when none provided', () => {
      const store = useDocumentStore()
      const data = { type: 'doc', content: [] }
      store.processMetanormaData(data)
      expect(store.title).toBe('Metanorma Document')
    })
  })
})
