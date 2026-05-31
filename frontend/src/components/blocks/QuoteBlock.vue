<template>
  <blockquote :id="block.attrs?.id" class="mn-quote">
    <MirrorRenderer :blocks="block.content || []" />
  </blockquote>
</template>

<script setup lang="ts">
import type { MirrorBlockNode } from '@/stores/documentStore'
import MirrorRenderer from '@/components/MirrorRenderer.vue'

defineProps<{ block: MirrorBlockNode }>()
</script>

<style scoped>
.mn-quote {
  position: relative;
  border-left: 3px solid var(--ebook-accent);
  padding: 0.75rem 1.25rem 0.75rem 1.5rem;
  margin: 1.5rem 0;
  font-style: italic;
  color: var(--ebook-text-muted);
  background: color-mix(in srgb, var(--ebook-bg-secondary) 60%, transparent);
  border-radius: 0 8px 8px 0;
}
</style>
