<template>
  <li>
    <a
      :href="`#${item.id}`"
      :class="['toc-link', { 'toc-active': isActive }]"
      @click.prevent="navigate"
    >
      <span v-if="number" class="toc-number">{{ number }}</span>
      {{ item.title }}
    </a>
    <ul v-if="item.children.length > 0" class="toc-list">
      <TocItem v-for="child in item.children" :key="child.id" :item="child" />
    </ul>
  </li>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useDocumentStore, type TocItem as TocItemType } from '@/stores/documentStore'
import { useUiStore } from '@/stores/uiStore'

const props = defineProps<{ item: TocItemType }>()

const documentStore = useDocumentStore()
const uiStore = useUiStore()

const isActive = computed(() => uiStore.activeSectionId === props.item.id)
const number = computed(() => documentStore.getNumbering(props.item.id))

function navigate() {
  const el = document.getElementById(props.item.id)
  if (el) {
    el.scrollIntoView({ behavior: 'smooth', block: 'start' })
    history.replaceState(null, '', `#${props.item.id}`)
  }
  if (window.innerWidth < 1024) uiStore.closeSidebar()
}
</script>

<style scoped>
.toc-list { list-style: none; padding-left: 12px; margin: 0; }
.toc-link {
  display: flex;
  align-items: baseline;
  gap: 6px;
  padding: 6px 16px;
  font-size: 0.82rem;
  color: var(--chrome-text-dim);
  text-decoration: none;
  border-radius: 6px;
  transition: background 0.1s ease, color 0.1s ease;
  cursor: pointer;
}
.toc-link:hover { background: var(--chrome-bg-hover); color: var(--chrome-text); }
.toc-active { color: var(--chrome-accent, #0d9488); background: color-mix(in srgb, var(--chrome-accent, #0d9488) 15%, transparent); }
.toc-number { font-family: ui-monospace, monospace; font-size: 0.75rem; color: var(--chrome-text-muted); min-width: 2em; }
</style>
