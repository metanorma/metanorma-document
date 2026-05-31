import { defineStore } from 'pinia'
import { ref, watch } from 'vue'

export type Theme = 'day' | 'sepia' | 'night' | 'oled'
export type FontFamily = 'sans' | 'serif'
export type ContentWidth = 'narrow' | 'default' | 'wide'
export type LineHeight = 'compact' | 'comfortable' | 'relaxed' | 'spacious'
export type ReadingMode = 'scroll' | 'paged'

const STORAGE_KEY = 'metanorma_ebook_preferences'

export const CONTENT_WIDTHS: Record<ContentWidth, string> = {
  narrow: '38rem',
  default: '58rem',
  wide: '82rem',
}

export const LINE_HEIGHTS: Record<LineHeight, string> = {
  compact: '1.4',
  comfortable: '1.6',
  relaxed: '1.8',
  spacious: '2.0',
}

const DEFAULTS = {
  fontSize: 18,
  fontFamily: 'sans' as FontFamily,
  contentWidth: 'default' as ContentWidth,
  theme: 'day' as Theme,
  lineHeight: 'comfortable' as LineHeight,
  readingMode: 'scroll' as ReadingMode,
  showProgress: true,
}

function loadPreferences(): Partial<typeof DEFAULTS> {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored) return JSON.parse(stored)
  } catch {}
  return {}
}

function savePreferences(prefs: Record<string, unknown>) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(prefs))
  } catch {}
}

function applyThemeClass(theme: Theme) {
  const html = document.documentElement
  html.classList.remove('theme-day', 'theme-sepia', 'theme-night', 'theme-oled')
  html.classList.add(`theme-${theme}`)
  const isDark = theme === 'night' || theme === 'oled'
  html.classList.toggle('dark', isDark)
}

const THEME_ORDER: Theme[] = ['day', 'sepia', 'night', 'oled']

export const useEbookStore = defineStore('ebook', () => {
  const prefs = loadPreferences()

  const fontSize = ref(prefs.fontSize ?? DEFAULTS.fontSize)
  const fontFamily = ref<FontFamily>(prefs.fontFamily ?? DEFAULTS.fontFamily)
  const contentWidth = ref<ContentWidth>(prefs.contentWidth ?? DEFAULTS.contentWidth)
  const theme = ref<Theme>(prefs.theme ?? DEFAULTS.theme)
  const lineHeight = ref<LineHeight>(prefs.lineHeight ?? DEFAULTS.lineHeight)
  const showProgress = ref(prefs.showProgress ?? DEFAULTS.showProgress)
  const readingMode = ref<ReadingMode>(prefs.readingMode ?? DEFAULTS.readingMode)

  const uiVisible = ref(true)
  const tocOpen = ref(false)
  const settingsOpen = ref(false)
  const focusMode = ref(false)

  applyThemeClass(theme.value)

  if (typeof document !== 'undefined') {
    document.body.classList.toggle('font-serif', fontFamily.value === 'serif')
    document.body.classList.toggle('font-sans', fontFamily.value === 'sans')
  }

  watch(
    [fontSize, fontFamily, contentWidth, theme, lineHeight, showProgress, readingMode],
    () => {
      savePreferences({
        fontSize: fontSize.value,
        fontFamily: fontFamily.value,
        contentWidth: contentWidth.value,
        theme: theme.value,
        lineHeight: lineHeight.value,
        showProgress: showProgress.value,
        readingMode: readingMode.value,
      })
    },
    { immediate: true }
  )

  watch(() => theme.value, (t) => applyThemeClass(t))

  function setFontSize(size: number) {
    fontSize.value = Math.max(12, Math.min(32, size))
  }

  function setFontFamily(f: FontFamily) {
    fontFamily.value = f
    document.body.classList.toggle('font-serif', f === 'serif')
    document.body.classList.toggle('font-sans', f === 'sans')
  }

  function setContentWidth(w: ContentWidth) {
    contentWidth.value = w
  }

  function setTheme(t: Theme) {
    theme.value = t
    applyThemeClass(t)
  }

  function cycleTheme() {
    const nextIndex = (THEME_ORDER.indexOf(theme.value) + 1) % THEME_ORDER.length
    setTheme(THEME_ORDER[nextIndex])
  }

  function setLineHeight(lh: LineHeight) {
    lineHeight.value = lh
  }

  function setFocusMode(fm: boolean) {
    focusMode.value = fm
  }

  function toggleFocusMode() {
    focusMode.value = !focusMode.value
  }

  function toggleToc() {
    tocOpen.value = !tocOpen.value
    if (tocOpen.value) settingsOpen.value = false
  }

  function toggleSettings() {
    settingsOpen.value = !settingsOpen.value
    if (settingsOpen.value) tocOpen.value = false
  }

  function closeAll() {
    tocOpen.value = false
    settingsOpen.value = false
  }

  function applyTheme() {
    applyThemeClass(theme.value)
  }

  function getThemeClass(): string {
    return `theme-${theme.value}`
  }

  function getCssVariables(): Record<string, string> {
    return {
      '--ebook-font-size': `${fontSize.value}px`,
      '--ebook-max-width': focusMode.value ? '100%' : CONTENT_WIDTHS[contentWidth.value],
      '--ebook-line-height': LINE_HEIGHTS[lineHeight.value],
    }
  }

  return {
    fontSize, fontFamily, contentWidth, theme,
    lineHeight, showProgress, readingMode,
    uiVisible, tocOpen, settingsOpen, focusMode,

    setFontSize, setFontFamily, setContentWidth, setTheme,
    cycleTheme, setLineHeight, setFocusMode, toggleFocusMode,
    toggleToc, toggleSettings, closeAll, applyTheme,

    getThemeClass, getCssVariables,
    CONTENT_WIDTHS, LINE_HEIGHTS,
  }
})
