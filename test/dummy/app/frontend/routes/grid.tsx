import React, { Suspense } from "react"
import { loadRuntimeModule } from "../runtime/importmap.js"

const ReactDataGrid = React.lazy(async () => {
  const module = await loadRuntimeModule("react-data-grid")

  return {
    default: module.default ?? module.DataGrid
  }
})

const columns = [
  { key: "id", name: "ID" },
  { key: "title", name: "Title" }
]

const rows = [
  { id: 1, title: "Propshaft build" },
  { id: 2, title: "Runtime import map" }
]

export function GridRoute() {
  return (
    <Suspense fallback={<p>Loading CDN component...</p>}>
      <ReactDataGrid columns={columns} rows={rows} />
    </Suspense>
  )
}

export default GridRoute