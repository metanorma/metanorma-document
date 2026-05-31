<template>
  <component :is="wrapInMarks(node.marks || [])">
    {{ node.text }}
  </component>
</template>

<script setup lang="ts">
import { h, type VNode, type Component } from 'vue'

interface Mark {
  type: string
  attrs?: Record<string, any>
}

interface MirrorTextNode {
  type: 'text'
  text: string
  marks?: Mark[]
}

defineProps<{
  node: MirrorTextNode
}>()

function markToTag(mark: Mark): string {
  switch (mark.type) {
    case 'emphasis':
      return 'em'
    case 'strong':
      return 'strong'
    case 'subscript':
      return 'sub'
    case 'superscript':
      return 'sup'
    case 'code':
      return 'code'
    case 'underline':
      return 'u'
    case 'strike':
      return 's'
    case 'link':
    case 'xref':
    case 'eref':
      return 'a'
    case 'footnote':
      return 'sup'
    case 'stem':
    case 'concept':
    case 'bcp14':
    case 'span':
    default:
      return 'span'
  }
}

function markAttrs(mark: Mark): Record<string, any> {
  switch (mark.type) {
    case 'link':
      return {
        href: mark.attrs?.href || '#',
        class: 'link-text hover:underline',
        target: '_blank',
        rel: 'noopener noreferrer',
      }
    case 'xref':
      return {
        href: `#${mark.attrs?.target || ''}`,
        class: 'xref link-text',
      }
    case 'eref':
      return {
        class: 'eref link-text',
        cite: mark.attrs?.citeas || '',
      }
    case 'emphasis':
      return { class: 'italic ebook-text' }
    case 'strong':
      return { class: 'font-bold heading-text' }
    case 'code':
      return { class: 'inline-code px-1.5 py-0.5 rounded text-sm font-mono border' }
    case 'footnote':
      return { class: 'footnote-inline' }
    case 'smallcap':
      return { class: 'smallcap' }
    case 'span': {
      const cls = mark.attrs?.class_attr
      return cls ? { class: cls } : {}
    }
    default:
      return {}
  }
}

function wrapInMarks(marks: Mark[]): Component {
  return {
    setup(_, { slots }) {
      return () => {
        if (marks.length === 0) {
          return h('span', {}, slots.default?.())
        }

        let inner: VNode | null = null
        for (let i = marks.length - 1; i >= 0; i--) {
          const mark = marks[i]
          const tag = markToTag(mark)
          const attrs = markAttrs(mark)

          if (inner) {
            inner = h(tag, attrs, inner)
          } else {
            inner = h(tag, attrs, slots.default?.())
          }
        }

        return inner || h('span', {}, slots.default?.())
      }
    },
  }
}
</script>

<style scoped>
.ebook-text { color: var(--ebook-text); }
.heading-text { color: var(--ebook-text-heading); }
.link-text { color: var(--ebook-link-color); transition: color 0.15s ease; }
.xref { text-decoration: none; border-bottom: 1px dashed color-mix(in srgb, var(--ebook-link-color) 40%, transparent); }
.xref:hover { border-bottom-color: var(--ebook-link-color); border-bottom-style: solid; }
.inline-code { background: var(--ebook-inline-code-bg); color: var(--ebook-inline-code-text); border-color: var(--ebook-inline-code-border); }
.footnote-inline { font-size: 0.75em; }
.smallcap { font-variant: small-caps; }
</style>
