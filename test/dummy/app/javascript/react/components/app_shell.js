import React from "react"
import StatusPanel from "@components/status_panel"
import { legacySpecifiers } from "@legacy/module_compat"

export default function AppShell({ environment, entrypoint }) {
  return React.createElement("section", { className: "importmap-react-shell" }, [
    React.createElement("h1", { key: "title" }, "Importmap for Rails"),
    React.createElement(
      "p",
      { key: "summary" },
      "React 18 is loaded through Importmap pins, while local modules resolve through Propshaft-friendly aliases."
    ),
    React.createElement(StatusPanel, {
      key: "status",
      environment,
      entrypoint,
      legacySpecifiers
    })
  ])
}
