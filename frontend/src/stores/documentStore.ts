import { defineStore } from 'pinia'
import { ref, shallowRef, computed } from 'vue'

// ============================================================
// MetanormaMirror (ProseMirror-style) Types
// ============================================================

export interface MirrorMark {
  type: 'emphasis' | 'strong' | 'subscript' | 'superscript' | 'code'
    | 'underline' | 'strike' | 'smallcap' | 'link' | 'xref'
    | 'eref' | 'footnote' | 'stem' | 'concept' | 'bcp14' | 'span'
  attrs?: Record<string, any>
}

export interface MirrorTextNode {
  type: 'text'
  text: string
  marks?: MirrorMark[]
}

export interface MirrorBlockNode {
  type: string
  attrs?: Record<string, any>
  content?: (MirrorTextNode | MirrorBlockNode)[]
}

export interface MirrorDocument {
  type: 'doc'
  attrs?: Record<string, any>
  content?: MirrorBlockNode[]
}

// ============================================================
// TOC Types
// ============================================================

export interface TocItem {
  id: string
  title: string
  type: string
  children: TocItem[]
  number?: string
}

interface DocumentMeta {
  title?: string
  flavor?: string
  docType?: string
  schemaVersion?: string
  sections: TocItem[]
  numbering: Record<string, string>
}

// ============================================================
// Document Store
// ============================================================

export const useDocumentStore = defineStore('document', () => {
  const documentMeta = ref<DocumentMeta | null>(null)
  const mirrorDocument = shallowRef<MirrorDocument | null>(null)
  const loadError = ref<string | null>(null)

  function processMetanormaData(data: any): void {
    if (data.type === 'doc' && Array.isArray(data.content)) {
      mirrorDocument.value = data as MirrorDocument

      if (data.toc?.sections) {
        documentMeta.value = {
          title: data.meta?.title || data.attrs?.title,
          flavor: data.meta?.flavor || data.attrs?.flavor,
          docType: data.meta?.type || data.attrs?.type,
          schemaVersion: data.meta?.schema_version || data.attrs?.schema_version,
          sections: data.toc.sections,
          numbering: data.toc.numbering || {},
        }
      } else {
        documentMeta.value = {
          title: data.meta?.title || data.attrs?.title,
          flavor: data.meta?.flavor || data.attrs?.flavor,
          docType: data.meta?.type || data.attrs?.type,
          schemaVersion: data.meta?.schema_version || data.attrs?.schema_version,
          sections: extractToc(data.content),
          numbering: {},
        }
      }
    }
  }

  function extractToc(nodes: any[]): TocItem[] {
    const sectionTypes = new Set([
      'clause', 'annex', 'terms', 'definitions', 'references',
      'abstract', 'foreword', 'introduction', 'acknowledgements',
    ])
    const items: TocItem[] = []
    for (const node of nodes) {
      if (sectionTypes.has(node.type) && node.attrs?.id) {
        items.push({
          id: node.attrs.id,
          title: node.attrs.title || node.type,
          type: node.type,
          children: node.content ? extractToc(node.content) : [],
        })
      }
    }
    return items
  }

  function loadFromWindow(): void {
    loadError.value = null
    const data = (window as any).METANORMA_DATA
    if (data) {
      processMetanormaData(data)
      delete (window as any).METANORMA_DATA
    } else {
      fetch('metanorma.data.json')
        .then(res => {
          if (!res.ok) throw new Error('Failed to load metanorma.data.json')
          return res.json()
        })
        .then(data => processMetanormaData(data))
        .catch(err => {
          console.error('Failed to load document data:', err)
          loadError.value = err instanceof Error ? err.message : 'Failed to load document'
        })
    }
  }

  const title = computed(() => {
    return documentMeta.value?.title || mirrorDocument.value?.attrs?.title || 'Metanorma Document'
  })
  const flavor = computed(() => documentMeta.value?.flavor || '')
  const docType = computed(() => documentMeta.value?.docType || '')
  const sections = computed(() => documentMeta.value?.sections || [])
  const numbering = computed(() => documentMeta.value?.numbering || {})

  function getNumbering(id: string): string {
    return numbering.value[id] || ''
  }

  return {
    documentMeta,
    mirrorDocument,
    loadError,
    loadFromWindow,
    processMetanormaData,
    title,
    flavor,
    docType,
    sections,
    numbering,
    getNumbering,
  }
})
