<template>
  <header class="topbar">
    <div class="topbar-left">
      <button @click="$emit('toggleToc')" class="topbar-btn" title="Toggle TOC">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/></svg>
      </button>
      <span class="topbar-title">{{ title }}</span>
    </div>
    <div class="topbar-right">
      <button @click="$emit('toggleSettings')" class="topbar-btn" title="Settings">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.066 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.573 1.066c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.066-2.573c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
      </button>
    </div>
  </header>
</template>

<script setup lang="ts">
defineProps<{
  title: string
  sidebarOpen: boolean
}>()

defineEmits<{
  toggleToc: []
  toggleSettings: []
}>()
</script>

<style scoped>
.topbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 12px;
  background: var(--chrome-bg);
  border-bottom: 1px solid var(--chrome-border);
  z-index: 40;
  backdrop-filter: blur(8px);
}
.topbar-left, .topbar-right { display: flex; align-items: center; gap: 8px; }
.topbar-title { font-size: 0.85rem; font-weight: 600; color: var(--chrome-text); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 400px; }
.topbar-btn { display: flex; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: 8px; color: var(--chrome-text-dim); cursor: pointer; }
.topbar-btn:hover { background: var(--chrome-bg-hover); color: var(--chrome-text); }
</style>
