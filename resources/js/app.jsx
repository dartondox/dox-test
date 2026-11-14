import { createInertiaApp } from '@inertiajs/react'
import { createRoot } from 'react-dom/client'

// Not eager: each page is its own chunk, so the big pdfme page
// does not load on the other pages.
const pages = import.meta.glob('./Pages/**/*.jsx')

createInertiaApp({
  resolve: (name) => pages[`./Pages/${name}.jsx`](),
  setup({ el, App, props }) {
    createRoot(el).render(<App {...props} />)
  },
})
