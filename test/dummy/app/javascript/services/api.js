// Service layer for API calls
// This provides a consistent interface for all HTTP requests

import axios from "axios"

const apiClient = axios.create({
  baseURL: "/api",
  headers: {
    "Accept": "application/json",
    "Content-Type": "application/json"
  },
  timeout: 10000
})

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      console.warn("Unauthorized request")
    }
    return Promise.reject(error)
  }
)

export default apiClient