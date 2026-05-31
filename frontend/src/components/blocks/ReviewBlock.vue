<template>
  <div :id="block.attrs?.id" class="mn-review mb-4 border-l-3 rounded-md" :class="borderClass">
    <div v-if="block.attrs?.title || block.attrs?.reviewer" class="review-header">
      <span v-if="block.attrs?.title" class="review-title">{{ block.attrs.title }}</span>
      <span v-if="block.attrs?.reviewer" class="review-reviewer">— {{ block.attrs.reviewer }}</span>
    </div>
    <div class="review-content">
      <MirrorRenderer :blocks="block.content || []" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { MirrorBlockNode } from '@/stores/documentStore'
import MirrorRenderer from '@/components/MirrorRenderer.vue'

const props = defineProps<{ block: MirrorBlockNode }>()

const borderClass = computed(() => {
  switch (props.block.attrs?.review_type) {
    case 'editorial': return 'review-editorial'
    case 'technical': return 'review-technical'
    case 'general': return 'review-general'
    default: return 'review-general'
  }
})
</script>

<style scoped>
.mn-review { border-left: 3px solid var(--ebook-border); padding: 0.75rem 1rem; background: var(--ebook-bg-secondary); }
.review-header { font-size: 0.85rem; font-weight: 600; margin-bottom: 0.5rem; }
.review-title { color: var(--ebook-text-heading); }
.review-reviewer { color: var(--ebook-text-muted); font-weight: 400; }
.review-content { font-size: 0.9rem; }
.review-editorial { border-left-color: #f59e0b; }
.review-technical { border-left-color: #ef4444; }
.review-general { border-left-color: #3b82f6; }
</style>
