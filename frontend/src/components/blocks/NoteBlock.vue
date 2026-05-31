<template>
  <div :id="block.attrs?.id" class="mn-note">
    <div class="note-title">Note</div>
    <div class="note-content">
      <MirrorRenderer :blocks="block.content || []" />
    </div>
  </div>
</template>

<script setup lang="ts">
import type { MirrorBlockNode } from '@/stores/documentStore'
import MirrorRenderer from '@/components/MirrorRenderer.vue'

defineProps<{ block: MirrorBlockNode }>()
</script>

<style scoped>
.mn-note { padding: 1rem 1.25rem; margin: 1.25rem 0; border-radius: 8px; border-left: 3px solid #0d9488; background: color-mix(in srgb, var(--ebook-bg-secondary) 50%, transparent); }
.note-title { font-weight: 700; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.04em; color: #0d9488; margin-bottom: 6px; }
.note-content { color: var(--ebook-text); }
</style>
