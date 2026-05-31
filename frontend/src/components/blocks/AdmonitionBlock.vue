<template>
  <div :class="getAdmonitionClass(block.attrs?.type)" class="admonition">
    <div class="admonition-icon" v-html="getAdmonitionIconSvg(block.attrs?.type)"></div>
    <div class="admonition-content">
      <div class="admonition-title">{{ getAdmonitionTitle(block.attrs?.type) }}</div>
      <MirrorRenderer :blocks="block.content || []" />
    </div>
  </div>
</template>

<script setup lang="ts">
import type { MirrorBlockNode } from '@/stores/documentStore'
import MirrorRenderer from '@/components/MirrorRenderer.vue'

defineProps<{ block: MirrorBlockNode }>()

const ADMONITION_TITLES: Record<string, string> = {
  danger: 'Danger', caution: 'Caution', warning: 'Warning',
  important: 'Important', 'safety precautions': 'Safety Precautions',
  editorial: 'Editorial', tip: 'Tip', note: 'Note', commentary: 'Commentary',
}

function getAdmonitionClass(type: string | undefined): string {
  switch (type) {
    case 'note': return 'admonition-note'
    case 'warning': return 'admonition-warning'
    case 'danger': return 'admonition-danger'
    case 'caution': return 'admonition-caution'
    case 'important': return 'admonition-important'
    case 'tip': return 'admonition-tip'
    case 'editorial': return 'admonition-editorial'
    default: return 'admonition-note'
  }
}

function getAdmonitionIconSvg(type: string | undefined): string {
  const s = 'width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"'
  switch (type) {
    case 'note':
      return `<svg ${s}><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>`
    case 'warning':
      return `<svg ${s}><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>`
    case 'danger':
      return `<svg ${s}><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>`
    case 'caution':
      return `<svg ${s}><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>`
    case 'important':
      return `<svg ${s}><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>`
    case 'tip':
      return `<svg ${s}><path d="M9 18h6"/><path d="M10 22h4"/><path d="M12 2a7 7 0 00-4 12.7V17h8v-2.3A7 7 0 0012 2z"/></svg>`
    default:
      return `<svg ${s}><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>`
  }
}

function getAdmonitionTitle(type: string | undefined): string {
  return ADMONITION_TITLES[type || ''] || (type ? type.charAt(0).toUpperCase() + type.slice(1) : 'Note')
}
</script>

<style scoped>
.admonition { display: flex; gap: 12px; padding: 14px 16px; border-radius: 8px; margin: 16px 0; }
.admonition-icon { flex-shrink: 0; width: 20px; height: 20px; margin-top: 1px; }
.admonition-icon :deep(svg) { width: 20px; height: 20px; }
.admonition-title { font-weight: 700; margin-bottom: 4px; text-transform: uppercase; font-size: 0.75em; letter-spacing: 0.04em; }
.admonition-content { flex: 1; min-width: 0; }
.admonition-note { background: color-mix(in srgb, #0d9488 10%, var(--ebook-bg)); color: color-mix(in srgb, #0d9488 70%, var(--ebook-text)); border-left: 3px solid #0d9488; }
.admonition-warning { background: color-mix(in srgb, #eab308 10%, var(--ebook-bg)); color: color-mix(in srgb, #eab308 70%, var(--ebook-text)); border-left: 3px solid #eab308; }
.admonition-danger { background: color-mix(in srgb, #ef4444 10%, var(--ebook-bg)); color: color-mix(in srgb, #ef4444 70%, var(--ebook-text)); border-left: 3px solid #ef4444; }
.admonition-caution { background: color-mix(in srgb, #f97316 10%, var(--ebook-bg)); color: color-mix(in srgb, #f97316 70%, var(--ebook-text)); border-left: 3px solid #f97316; }
.admonition-important { background: color-mix(in srgb, #a855f7 10%, var(--ebook-bg)); color: color-mix(in srgb, #a855f7 70%, var(--ebook-text)); border-left: 3px solid #a855f7; }
.admonition-tip { background: color-mix(in srgb, #22c55e 10%, var(--ebook-bg)); color: color-mix(in srgb, #22c55e 70%, var(--ebook-text)); border-left: 3px solid #22c55e; }
.admonition-editorial { background: color-mix(in srgb, #6366f1 10%, var(--ebook-bg)); color: color-mix(in srgb, #6366f1 70%, var(--ebook-text)); border-left: 3px solid #6366f1; }
</style>
