// Action Cable consumer for channels
// This module provides a shared consumer instance for all channels
// It handles connection lifecycle, reconnection logic, and authentication

import { createConsumer } from "@rails/actioncable"

let consumer = null

export function getConsumer() {
  if (consumer) return consumer

  consumer = createConsumer()
  consumer.connection.monitor.reconnectAttempts = 5
  consumer.connection.monitor.staleThreshold = 6

  return consumer
}

export function resetConsumer() {
  if (consumer) {
    consumer.disconnect()
    consumer = null
  }
}

export { consumer }