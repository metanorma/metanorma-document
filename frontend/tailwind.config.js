/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './src/**/*.{vue,ts,html}',
  ],
  darkMode: 'class',
  corePlugins: {
    // Preflight resets bare elements, which would clobber the classic
    // renderer's SSR body inlined by InlineFormat (no-JS placeholder).
    preflight: false,
  },
  theme: {
    extend: {
      colors: {
        cream: '#faf8f5',
        charcoal: '#2d2d2d',
        teal: '#0d9488',
        navy: '#1e3a5f'
      }
    }
  },
  plugins: [],
}
