/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './src/**/*.{vue,ts,html}',
  ],
  darkMode: 'class',
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
