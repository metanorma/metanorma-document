<template>
  <p :id="block.attrs?.id" class="mn-paragraph mb-3 ebook-text leading-relaxed">
    <template v-for="(child, ci) in block.content" :key="ci">
      <TextRenderer v-if="child.type === 'text'" :node="child as any" />
      <br v-else-if="child.type === 'soft_break'" />
      <sup v-else-if="child.type === 'footnote_marker'" class="footnote-marker">
        <a :href="`#${child.attrs?.ref_id}`" :id="child.attrs?.id">{{ child.attrs?.number || '*' }}</a>
      </sup>
    </template>
  </p>
</template>

<script setup lang="ts">
import type { MirrorBlockNode } from '@/stores/documentStore'
import TextRenderer from '@/components/TextRenderer.vue'

defineProps<{ block: MirrorBlockNode }>()
</script>

<style scoped>
.ebook-text { color: var(--ebook-text); }
.footnote-marker { font-size: 0.75em; vertical-align: super; line-height: 0; }
.footnote-marker a { color: var(--ebook-link-color); text-decoration: none; cursor: pointer; }
.footnote-marker a:hover { text-decoration: underline; }
</style>
