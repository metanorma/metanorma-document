<template>
  <figure :id="block.attrs?.id" class="mn-figure">
    <template v-if="block.type === 'image'">
      <img :src="block.attrs?.src" :alt="block.attrs?.alt || ''"
           :height="block.attrs?.height" :width="block.attrs?.width"
           loading="lazy" class="figure-image" />
    </template>
    <template v-else>
      <MirrorRenderer :blocks="block.content || []" />
    </template>
    <figcaption v-if="block.attrs?.title" class="figure-caption">{{ block.attrs.title }}</figcaption>
  </figure>
</template>

<script setup lang="ts">
import type { MirrorBlockNode } from '@/stores/documentStore'
import MirrorRenderer from '@/components/MirrorRenderer.vue'

defineProps<{ block: MirrorBlockNode }>()
</script>

<style scoped>
.mn-figure { margin: 2rem 0; padding: 1rem; background: color-mix(in srgb, var(--ebook-bg-secondary) 40%, transparent); border-radius: 10px; border: 1px solid color-mix(in srgb, var(--ebook-border) 60%, transparent); }
.figure-image { max-width: 100%; height: auto; border-radius: 6px; display: block; margin: 0 auto; }
.figure-caption { text-align: center; font-size: 0.78rem; color: var(--ebook-text-muted); margin-top: 0.6rem; font-style: italic; }
</style>
