import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUiStore = defineStore('ui', () => {
  const sidebarOpen = ref(false)
  const activeSectionId = ref<string | null>(null)

  function openSidebar() {
    sidebarOpen.value = true
  }

  function closeSidebar() {
    sidebarOpen.value = false
  }

  function toggleSidebar() {
    sidebarOpen.value = !sidebarOpen.value
  }

  function setActiveSection(id: string) {
    activeSectionId.value = id
  }

  return {
    sidebarOpen,
    activeSectionId,
    openSidebar,
    closeSidebar,
    toggleSidebar,
    setActiveSection,
  }
})
