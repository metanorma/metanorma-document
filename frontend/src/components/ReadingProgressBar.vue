<template>
  <div v-if="visible" class="reading-progress">
    <div class="reading-progress-bar" :style="{ width: `${progress}%` }"></div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  progress: number
  visible: boolean
}>()
</script>

<style scoped>
.reading-progress {
  position: fixed;
  top: 56px;
  left: 0;
  right: 0;
  height: 3px;
  background: var(--chrome-border);
  z-index: 39;
}
.reading-progress-bar {
  height: 100%;
  background: var(--chrome-accent, #0d9488);
  transition: width 0.1s ease-out;
}
</style>
