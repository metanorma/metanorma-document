<template>
  <div :id="block.attrs?.id" class="mn-fallback">
    <div class="fallback-type">{{ block.type }}</div>
    <MirrorRenderer v-if="block.content?.length" :blocks="block.content" />
  </div>
</template>

<script setup lang="ts">
import type { MirrorBlockNode } from '@/stores/documentStore'
import MirrorRenderer from '@/components/MirrorRenderer.vue'

defineProps<{ block: MirrorBlockNode }>()
</script>

<style scoped>
.mn-fallback { padding: 0.5rem 0; }
.fallback-type { font-family: ui-monospace, monospace; font-size: 0.65rem; color: var(--ebook-text-muted); opacity: 0.5; text-transform: uppercase; letter-spacing: 0.05em; }
</style>
