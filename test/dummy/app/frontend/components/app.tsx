import React, { Suspense, useState } from "react"

const GridRoute = React.lazy(() => import("../routes/grid.js"))

export function App() {
  const [route, setRoute] = useState("home")

  return (
    <section>
      <h1>Importmap Runtime Loader</h1>
      <div>
        <button type="button" onClick={() => setRoute("home")}>Home</button>
        <button type="button" onClick={() => setRoute("grid")}>Grid</button>
      </div>
      {route === "home" ? (
        <p>TypeScript modules are compiled into Propshaft builds and React routes stay lazily loaded.</p>
      ) : (
        <Suspense fallback={<p>Loading route chunk...</p>}>
          <GridRoute />
        </Suspense>
      )}
    </section>
  )
}