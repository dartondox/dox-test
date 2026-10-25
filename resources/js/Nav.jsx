import { Link, router, usePage } from '@inertiajs/react'

export default function Nav() {
  const { appName, auth } = usePage().props
  return (
    <nav>
      <strong>{appName}</strong> | <Link href="/inertia">Home</Link> |{' '}
      <Link href="/inertia/notes">Notes</Link> |{' '}
      {auth?.user ? (
        <>
          <Link href="/inertia/dashboard">Dashboard</Link> | {auth.user.name}{' '}
          <button onClick={() => router.post('/inertia/logout')}>Logout</button>
        </>
      ) : (
        <Link href="/inertia/login">Login</Link>
      )}
    </nav>
  )
}
