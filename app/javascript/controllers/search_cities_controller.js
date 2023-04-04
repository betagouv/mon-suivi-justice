import Rails from "@rails/ujs";
import { ApplicationController, useDebounce } from 'stimulus-use'

export default class extends ApplicationController {
    static targets = ["results", "query"]
    static debounces = ['search']

    connect() {
        useDebounce(this, { wait: 500 })
    }

    search() {
        if (this.query == "") {
            this.reset()
            return
        }

        if (this.query == this.previousQuery) {
            return
        }
        this.previousQuery = this.query

        this.abortPreviousFetchRequest()

        this.abortController = new AbortController()
        fetch('/search_cities?city_name=' + this.query, { signal: this.abortController.signal })
            .then(response => response.text())
            .then(html => {
                console.log(html)
                this.handleResults(html)
            })
            .catch((e) => { 
                console.log(e)
            })
    }

    // private
    
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

    get query() {
        return this.queryTarget.value
    }

    handleResults(data) {
        this.resultsTarget.innerHTML = data
    }
}