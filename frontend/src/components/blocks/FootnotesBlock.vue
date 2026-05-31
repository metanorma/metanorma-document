<template>
  <div class="mn-footnotes">
    <ol class="footnotes-list">
      <li v-for="(fn, index) in (block.content || [])" :key="index" :id="(fn as any).attrs?.id" class="footnote-entry">
        <MirrorRenderer :blocks="(fn as any).content || []" />
        <a v-if="(fn as any).attrs?.ref_id" :href="`#${(fn as any).attrs.ref_id}`" class="footnote-backref">&#8617;</a>
      </li>
    </ol>
  </div>
</template>

<script setup lang="ts">
import type { MirrorBlockNode } from '@/stores/documentStore'
import MirrorRenderer from '@/components/MirrorRenderer.vue'

defineProps<{ block: MirrorBlockNode }>()
</script>

<style scoped>
.mn-footnotes { margin-top: 3rem; padding-top: 1.5rem; border-top: 1px solid var(--ebook-border); }
.footnotes-list { list-style-type: decimal; padding-left: 1.5rem; font-size: 0.85rem; color: var(--ebook-text-muted); }
.footnote-entry { margin-bottom: 0.5rem; line-height: 1.6; }
.footnote-backref { color: var(--ebook-link-color); text-decoration: none; margin-left: 4px; }
.footnote-backref:hover { text-decoration: underline; }
</style>
