import { describe, it, expect, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useUiStore } from '../uiStore'

describe('useUiStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('has correct defaults', () => {
    const store = useUiStore()
    expect(store.sidebarOpen).toBe(false)
    expect(store.activeSectionId).toBeNull()
  })

  it('opens sidebar', () => {
    const store = useUiStore()
    store.openSidebar()
    expect(store.sidebarOpen).toBe(true)
  })

  it('closes sidebar', () => {
    const store = useUiStore()
    store.openSidebar()
    store.closeSidebar()
    expect(store.sidebarOpen).toBe(false)
  })

  it('toggles sidebar', () => {
    const store = useUiStore()
    store.toggleSidebar()
    expect(store.sidebarOpen).toBe(true)
    store.toggleSidebar()
    expect(store.sidebarOpen).toBe(false)
  })

  it('sets active section', () => {
    const store = useUiStore()
    store.setActiveSection('scope')
    expect(store.activeSectionId).toBe('scope')
  })
})
