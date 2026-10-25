import { Deferred, router } from '@inertiajs/react'
import Nav from '../Nav'

export default function Home({ greeting, time, stats, tip }) {
  return (
    <main>
      <Nav />
      <h1>{greeting}</h1>
      <p>Server time: {time}</p>
      <Deferred data="stats" fallback={<p>Loading stats...</p>}>
        <p>Notes: {stats?.notes}</p>
      </Deferred>
      <p>
        <button onClick={() => router.reload({ only: ['tip'] })}>Load tip</button>{' '}
        {tip}
      </p>
    </main>
  )
}
