<template>
  <div :id="block.attrs?.id" class="mn-example">
    <div class="example-label">EXAMPLE</div>
    <div class="example-content">
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
.mn-example { padding: 1rem 1.25rem; margin: 1.25rem 0; border-radius: 8px; border-left: 3px solid #3b82f6; background: color-mix(in srgb, var(--ebook-bg-secondary) 50%, transparent); }
.example-label { font-family: ui-monospace, monospace; font-weight: 700; font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.08em; color: #3b82f6; margin-bottom: 6px; }
.example-content { color: var(--ebook-text); }
</style>
