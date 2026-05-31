<template>
  <component :is="meta.tag" :id="block.attrs?.id" class="mn-clause mb-6">
    <component
      v-if="block.attrs?.title"
      :is="meta.headingTag"
      :class="['heading-with-anchor heading-text', meta.headingClass]"
    >
      <a
        v-if="block.attrs?.id"
        :href="`#${block.attrs.id}`"
        class="anchor-link"
        @click.prevent="copyAnchor(block.attrs.id)"
      >#</a>
      <span v-if="getNumbering(block.attrs?.id)" class="muted-text mr-2">{{ getNumbering(block.attrs?.id) }}</span>
      {{ block.attrs.title }}
    </component>
    <MirrorRenderer :blocks="block.content || []" />
  </component>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { MirrorBlockNode } from '@/stores/documentStore'
import { useDocumentStore } from '@/stores/documentStore'
import { SECTION_META } from '@/utils/typeMetadata'
import MirrorRenderer from '@/components/MirrorRenderer.vue'

const props = defineProps<{ block: MirrorBlockNode }>()

const documentStore = useDocumentStore()

const meta = computed(() => {
  return SECTION_META[props.block.type] || SECTION_META['clause']!
})

function getNumbering(id: string | undefined): string {
  if (!id) return ''
  return documentStore.getNumbering(id)
}

function copyAnchor(id: string) {
  const url = `${window.location.origin}${window.location.pathname}#${id}`
  navigator.clipboard.writeText(url)
}
</script>

<style scoped>
.heading-text { color: var(--ebook-text-heading); }
.muted-text { color: var(--ebook-text-muted); }
.heading-with-anchor { position: relative; scroll-margin-top: 70px; }
.anchor-link { position: absolute; left: -1.2em; color: var(--ebook-text-muted); opacity: 0; transition: opacity 0.15s ease; text-decoration: none; font-weight: 400; font-size: 0.7em; }
.heading-with-anchor:hover .anchor-link, .anchor-link:focus { opacity: 1; }
</style>
