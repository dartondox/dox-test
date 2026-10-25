import { usePage } from '@inertiajs/react'
import Nav from '../Nav'

export default function Dashboard() {
  const { user } = usePage().props.auth
  return (
    <main>
      <Nav />
      <h1>Dashboard</h1>
      <p>
        Logged in as <strong>{user.name}</strong> ({user.email})
      </p>
    </main>
  )
}
