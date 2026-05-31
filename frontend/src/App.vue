<template>
  <div :class="['h-screen overflow-hidden', ebookStore.getThemeClass()]" :style="ebookStore.getCssVariables()">
    <div id="metanorma-error" class="error-fallback" style="display:none">
      <div class="error-content">
        <svg class="error-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
        <h2>Something went wrong</h2>
        <p class="error-message">An error occurred while rendering this document.</p>
        <button @click="reload" class="error-retry">Reload page</button>
      </div>
    </div>
    <DocumentReader />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useEbookStore } from '@/stores/ebookStore'
import { useDocumentStore } from '@/stores/documentStore'
import DocumentReader from '@/components/DocumentReader.vue'

const ebookStore = useEbookStore()
const documentStore = useDocumentStore()

documentStore.loadFromWindow()

onMounted(() => {
  ebookStore.applyTheme()
})

function reload() {
  window.location.reload()
}
</script>

<style>
.error-fallback {
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: #fefce8;
  color: #1a1a1a;
  display: flex;
  align-items: center;
  justify-content: center;
}
.error-content {
  text-align: center;
  max-width: 400px;
  padding: 2rem;
}
.error-icon {
  width: 48px;
  height: 48px;
  margin: 0 auto 1rem;
  color: #f59e0b;
}
.error-content h2 {
  font-size: 1.25rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}
.error-message {
  font-size: 0.9rem;
  color: #6b7280;
  margin-bottom: 1.5rem;
}
.error-retry {
  padding: 8px 20px;
  font-size: 0.85rem;
  font-weight: 600;
  border-radius: 8px;
  background: #0d9488;
  color: #fff;
  cursor: pointer;
}
.error-retry:hover {
  background: #0f766e;
}
</style>
