const aliases = {
  "packs/application": "application",
  "packs/app_shell": "@components/app_shell",
  "packs/status_panel": "@components/status_panel"
}

export const legacySpecifiers = Object.keys(aliases)

export function resolveLegacySpecifier(specifier) {
  return aliases[specifier] || specifier
}
