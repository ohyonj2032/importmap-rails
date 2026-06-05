import React from "react"

export default function StatusPanel({ environment, entrypoint, legacySpecifiers }) {
  const rows = [
    ["environment", environment],
    ["entrypoint", entrypoint],
    ["legacy compatibility", legacySpecifiers.join(", ")]
  ]

  return React.createElement(
    "dl",
    { className: "importmap-react-status" },
    rows.flatMap(([label, value]) => [
      React.createElement("dt", { key: `${label}-label` }, label),
      React.createElement("dd", { key: `${label}-value` }, value)
    ])
  )
}
