import Rails from "@rails/ujs";
import { ApplicationController, useDebounce } from 'stimulus-use'

export default class extends ApplicationController {
    static targets = ["results", "query"]
    static debounces = ['search']

    connect() {
        console.log('search cities controller connected')
        useDebounce(this, { wait: 500 })
    }

    get query() {
        return this.queryTarget.value
    }

    search() {
        if (this.query.length < 3) {
            return
          }

        if (this.query == this.previousQuery) {
            return
        }
        this.previousQuery = this.query

        this.abortPreviousFetchRequest()

        this.abortController = new AbortController()
        fetch('/cities/search?q=' + this.query, { signal: this.abortController.signal })
            .then(response => response.text())
            .then(html => {
                this.handleResults(html)
            })
            .catch((e) => { 
                console.log(e)
            })
    }
    
    reset() {
        this.resultsTarget.innerHTML = ""
        this.queryTarget.value = ""
        this.previousQuery = null
    }

    abortPreviousFetchRequest() {
        if (this.abortController) {
            this.abortController.abort()
        }
    }

    handleResults(data) {
        this.resultsTarget.innerHTML = data
    }

    clearResults() {
        this.resultsTarget.innerHTML = ""
    }
}