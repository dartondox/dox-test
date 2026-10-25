import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig(({ command }) => ({
  plugins: [react()],
  // public/ holds the Dox public files, do not copy it into the build
  publicDir: false,
  // the built files are served from /build/
  base: command === 'build' ? '/build/' : '/',
  server: { origin: 'http://localhost:5173' },
  build: {
    manifest: true,
    outDir: 'public/build',
    rollupOptions: { input: 'resources/js/app.jsx' },
  },
}))
