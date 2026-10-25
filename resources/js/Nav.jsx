import { Link, usePage } from '@inertiajs/react'

export default function Nav() {
  const { appName } = usePage().props
  return (
    <nav>
      <strong>{appName}</strong> | <Link href="/inertia">Home</Link> |{' '}
      <Link href="/inertia/notes">Notes</Link>
    </nav>
  )
}
