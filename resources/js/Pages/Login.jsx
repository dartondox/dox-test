import { useForm } from '@inertiajs/react'
import Nav from '../Nav'

export default function Login({ errors }) {
  const form = useForm({ email: '', password: '' })

  function submit(e) {
    e.preventDefault()
    form.post('/inertia/login', { onFinish: () => form.reset('password') })
  }

  return (
    <main>
      <Nav />
      <h1>Login</h1>
      <form onSubmit={submit}>
        <p>
          <input type="email" placeholder="Email" value={form.data.email} onChange={(e) => form.setData('email', e.target.value)} />
          {errors.email && <span style={{ color: 'red' }}> {errors.email}</span>}
        </p>
        <p>
          <input type="password" placeholder="Password" value={form.data.password} onChange={(e) => form.setData('password', e.target.value)} />
          {errors.password && <span style={{ color: 'red' }}> {errors.password}</span>}
        </p>
        <button disabled={form.processing}>Log in</button>
      </form>
    </main>
  )
}
