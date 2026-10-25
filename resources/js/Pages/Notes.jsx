import { router, useForm } from '@inertiajs/react'
import Nav from '../Nav'

export default function Notes({ notes, errors }) {
  const form = useForm({ text: '' })

  function submit(e) {
    e.preventDefault()
    form.post('/inertia/notes', { onSuccess: () => form.reset() })
  }

  return (
    <main>
      <Nav />
      <h1>Notes</h1>
      <form onSubmit={submit}>
        <input value={form.data.text} onChange={(e) => form.setData('text', e.target.value)} />
        <button disabled={form.processing}>Add</button>
        {errors.text && <p style={{ color: 'red' }}>{errors.text}</p>}
      </form>
      <ul>
        {notes.map((note) => (
          <li key={note.id}>
            {note.text}{' '}
            <button onClick={() => router.delete(`/inertia/notes/${note.id}`)}>x</button>
          </li>
        ))}
      </ul>
    </main>
  )
}
