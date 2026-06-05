import React, { Suspense, useState } from "react"

const GridRoute = React.lazy(() => import("../routes/grid.js"))

export function App() {
  const [route, setRoute] = useState("home")

  return React.createElement(
    "section",
    null,
    React.createElement("h1", null, "Importmap Runtime Loader"),
    React.createElement(
      "div",
      null,
      React.createElement("button", { type: "button", onClick: () => setRoute("home") }, "Home"),
      React.createElement("button", { type: "button", onClick: () => setRoute("grid") }, "Grid")
    ),
    route === "home"
      ? React.createElement(
          "p",
          null,
          "TypeScript modules are compiled into Propshaft builds and React routes stay lazily loaded."
        )
      : React.createElement(
          Suspense,
          { fallback: React.createElement("p", null, "Loading route chunk...") },
          React.createElement(GridRoute)
        )
  )
}