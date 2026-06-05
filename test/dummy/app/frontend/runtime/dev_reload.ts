export function startDevelopmentReloading() {
  const currentDigest = document.querySelector<HTMLMetaElement>('meta[name="importmap-digest"]')
  const versionPath = document.querySelector<HTMLMetaElement>('meta[name="importmap-version-path"]')

  if (!currentDigest || !versionPath) {
    return
  }

  let digest = currentDigest.content

  window.setInterval(async () => {
    try {
      const response = await fetch(versionPath.content, {
        headers: { Accept: "application/json" },
        cache: "no-store",
        credentials: "same-origin"
      })

      if (!response.ok) {
        return
      }

      const payload = await response.json() as { digest?: string }

      if (payload.digest && payload.digest !== digest) {
        window.location.reload()
      }
    } catch (_error) {
    }
  }, 1500)
}