import { createInertiaApp } from '@inertiajs/react'
import { createRoot } from 'react-dom/client'

const pages = import.meta.glob('./Pages/**/*.jsx', { eager: true })

createInertiaApp({
  // ponytail: Inertia v3 reads the first page from a <script data-page>
  // tag. dox_inertia writes it on <div id="app" data-page>, so pass it here.
  page: JSON.parse(document.getElementById('app').dataset.page),
  resolve: (name) => pages[`./Pages/${name}.jsx`],
  setup({ el, App, props }) {
    createRoot(el).render(<App {...props} />)
  },
})
