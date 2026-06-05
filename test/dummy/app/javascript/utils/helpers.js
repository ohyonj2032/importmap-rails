// Utility functions module
// Shared helpers used across the application

import { format, formatDistance } from "date-fns"

export function formatDate(date, pattern = "yyyy-MM-dd") {
  return format(date, pattern)
}

export function timeAgo(date) {
  return formatDistance(date, new Date(), { addSuffix: true })
}

export function debounce(fn, delay = 300) {
  let timeoutId
  return function (...args) {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(() => fn.apply(this, args), delay)
  }
}

export function throttle(fn, limit = 300) {
  let inThrottle
  return function (...args) {
    if (!inThrottle) {
      fn.apply(this, args)
      inThrottle = true
      setTimeout(() => (inThrottle = false), limit)
    }
  }
}