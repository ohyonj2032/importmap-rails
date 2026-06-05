import "rich_text"
import "controllers"

import React from "react"
import ReactDOM from "react-dom/client"

document.addEventListener("DOMContentLoaded", () => {
  const rootElement = document.getElementById("root")
  if (rootElement) {
    const root = ReactDOM.createRoot(rootElement)
    root.render(
      <React.StrictMode>
        <div>Hello React 18 with Importmap!</div>
      </React.StrictMode>
    )
  }
})
