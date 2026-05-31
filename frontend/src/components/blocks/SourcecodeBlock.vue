<template>
  <div :id="block.attrs?.id" class="mn-sourcecode">
    <div v-if="language" class="code-language-badge">{{ language }}</div>
    <pre class="code-block"><code>{{ code }}</code></pre>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { MirrorBlockNode } from '@/stores/documentStore'

const props = defineProps<{ block: MirrorBlockNode }>()

const language = computed(() => props.block.attrs?.language || '')
const code = computed(() => props.block.attrs?.text || extractText(props.block.content || []))

function extractText(content: any[]): string {
  return content.map(node => {
    if (node.type === 'text') return node.text || ''
    if (node.content) return extractText(node.content)
    return ''
  }).join('')
}
</script>

<style scoped>
.mn-sourcecode { margin: 1.5rem 0; border-radius: 8px; overflow: hidden; position: relative; }
.code-language-badge {
  display: inline-block;
  padding: 2px 10px;
  font-family: ui-monospace, monospace;
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  background: var(--ebook-bg-secondary);
  color: var(--ebook-text-muted);
  border-bottom: 1px solid var(--ebook-border);
  border-radius: 8px 8px 0 0;
}
.code-block {
  font-family: ui-monospace, monospace;
  font-size: 0.875rem;
  background: var(--chrome-bg-hover, #f1f5f9);
  padding: 1rem 1.25rem;
  overflow-x: auto;
  border: 1px solid var(--ebook-border);
  border-radius: 8px;
  margin: 0;
}
.code-block code { font-family: inherit; }
</style>
