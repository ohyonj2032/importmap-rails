import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "loading"]

  search() {
    const query = this.inputTarget.value.trim()
    
    if (query.length < 2) {
      this.resultsTarget.innerHTML = ''
      return
    }

    this.showLoading()
    this.performSearch(query)
  }

  async performSearch(query) {
    try {
      const searchUrl = `/search?q=${encodeURIComponent(query)}`
      const response = await fetch(searchUrl, {
        headers: {
          'Accept': 'text/html'
        }
      })
      
      if (response.ok) {
        const html = await response.text()
        this.resultsTarget.innerHTML = html
      }
    } catch (error) {
      console.error('Search error:', error)
      this.resultsTarget.innerHTML = '<p class="text-red-500">搜索出错了，请稍后重试</p>'
    } finally {
      this.hideLoading()
    }
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove('hidden')
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add('hidden')
    }
  }

  clear() {
    this.inputTarget.value = ''
    this.resultsTarget.innerHTML = ''
  }
}
