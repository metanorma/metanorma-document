<template>
  <aside :class="['sidebar', { 'sidebar-open': uiStore.sidebarOpen }]">
    <div class="sidebar-header">
      <h2 class="sidebar-title">{{ documentStore.title }}</h2>
      <button @click="uiStore.closeSidebar" class="sidebar-close" title="Close sidebar">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
      </button>
    </div>
    <nav class="sidebar-nav">
      <ul class="toc-list">
        <TocItem v-for="item in documentStore.sections" :key="item.id" :item="item" />
      </ul>
    </nav>
  </aside>
</template>

<script setup lang="ts">
import { useDocumentStore } from '@/stores/documentStore'
import { useUiStore } from '@/stores/uiStore'
import TocItem from './TocItem.vue'

const documentStore = useDocumentStore()
const uiStore = useUiStore()
</script>

<style scoped>
.sidebar {
  position: fixed;
  top: 0;
  left: 0;
  width: 280px;
  height: 100vh;
  background: var(--chrome-bg);
  border-right: 1px solid var(--chrome-border);
  transform: translateX(-100%);
  transition: transform 0.2s ease;
  z-index: 50;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.sidebar-open {
  transform: translateX(0);
}
@media (min-width: 1024px) {
  .sidebar-open { transform: translateX(0); }
}
.sidebar-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  border-bottom: 1px solid var(--chrome-border);
  min-height: 56px;
}
.sidebar-title {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--chrome-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 200px;
}
.sidebar-close {
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--chrome-text-dim);
  padding: 4px;
  border-radius: 6px;
  cursor: pointer;
}
.sidebar-close:hover { background: var(--chrome-bg-hover); }
.sidebar-nav { flex: 1; overflow-y: auto; padding: 8px 0; }
.toc-list { list-style: none; padding: 0; margin: 0; }
</style>
