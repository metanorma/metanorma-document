import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import './styles.css'

const pinia = createPinia()

const app = createApp(App)
app.use(pinia)

app.config.errorHandler = (err, _instance, info) => {
  console.error(`[Metanorma] ${info}:`, err)
  const el = document.getElementById('metanorma-error')
  if (el) {
    el.style.display = 'flex'
    const msg = el.querySelector('.error-message')
    if (msg) msg.textContent = err instanceof Error ? err.message : String(err)
  }
}

app.mount('#metanorma-app')
