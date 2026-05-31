import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import MirrorRenderer from '../../components/MirrorRenderer.vue'
import { useDocumentStore } from '../../stores/documentStore'
import fixture from '@test/fixtures/iso-document.json'

function mountRenderer(content: any[]) {
  setActivePinia(createPinia())
  const store = useDocumentStore()
  store.processMetanormaData(fixture)

  const wrapper = mount(MirrorRenderer, {
    props: { blocks: content },
    global: { plugins: [createPinia()] },
  })

  // Need to set up store after pinia is injected
  const store2 = useDocumentStore()
  store2.processMetanormaData(fixture)

  return wrapper
}

describe('MirrorRenderer with fixture data', () => {
  it('renders top-level sections', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('Foreword')
    expect(html).toContain('Scope')
    expect(html).toContain('Normative references')
    expect(html).toContain('Terms and definitions')
    expect(html).toContain('Test methods')
  })

  it('renders paragraphs with text content', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('ISO (the International Organization')
    expect(html).toContain('the test methods')
  })

  it('renders strong marks', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('the test methods')
    // Vue adds scoped data attributes and CSS classes, so check tag + text
    const strongEls = wrapper.findAll('strong')
    const texts = strongEls.map(e => e.text())
    expect(texts).toContain('the test methods')
  })

  it('renders emphasis marks', () => {
    const wrapper = mountRenderer(fixture.content!)

    const emEls = wrapper.findAll('em')
    const texts = emEls.map(e => e.text())
    expect(texts).toContain('Oryza sativa L.')
    expect(texts).toContain('Oryza glaberrima')
  })

  it('renders bullet lists', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('Milling quality assessment')
    expect(html).toContain('Moisture content determination')
    expect(html).toContain('<ul')
    expect(html).toContain('<li')
  })

  it('renders tables with thead and tbody', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('Parameter')
    expect(html).toContain('Method')
    expect(html).toContain('Unit')
    expect(html).toContain('ISO 712')
    expect(html).toContain('ISO 520')
  })

  it('renders admonition blocks', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('(20 ± 2) °C')
    expect(html).toContain('admonition-warning')
  })

  it('renders sourcecode blocks', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('moisture_content')
    expect(html).toContain('python')
  })

  it('renders figures with images', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('grain.png')
    expect(html).toContain('Grain structure diagram')
    expect(html).toContain('Grain structure')
  })

  it('renders ordered lists', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('Weigh the sample')
    expect(html).toContain('Dry at 130 °C')
    expect(html).toContain('<ol')
  })

  it('renders blockquotes', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('Precision is the soul of science')
    expect(html).toContain('blockquote')
  })

  it('renders nested clauses (terms)', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('rice')
    expect(html).toContain('Oryza sativa L.')
  })

  it('renders xref marks as links', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('ISO 712')
    // xref should produce an <a> tag with href to target
    expect(html).toMatch(/href.*iso712/)
  })

  it('renders notes with title', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('Note')
    expect(html).toContain('paddy rice')
  })

  it('renders examples', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('Long-grain rice')
  })

  it('renders formula blocks', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('formula')
  })

  it('renders footnotes section', () => {
    const wrapper = mountRenderer(fixture.content!)
    const html = wrapper.html()

    expect(html).toContain('Published by ISO')
  })

  it('renders document with no content without error', () => {
    const wrapper = mountRenderer([])
    expect(wrapper.html()).toContain('content-blocks')
  })
})
