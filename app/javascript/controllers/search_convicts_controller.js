import { ApplicationController, useDebounce } from 'stimulus-use'

export default class extends ApplicationController {
    static targets = ["results", "query", "table"]
    static debounces = ['search']

    connect() {
        useDebounce(this, { wait: 500 })
    }

    get query() {
        return this.queryTarget.value
    }

    search() {
        if (this.query.length === 0) {
            this.tableTarget.style.display = 'block';
            this.reset();
            return;
        }

        if (this.query == this.previousQuery) {
            return
        }

        this.previousQuery = this.query

        const digitRegex = /\d/g;
        const digitCount = (this.query.match(digitRegex) || []).length;
        const nonDigitRegex = /(?!\+)\D/;
        const containsNonDigit = nonDigitRegex.test(this.query);

        if (digitCount < 4 && !containsNonDigit) {
            return;
        }

        this.abortPreviousFetchRequest()

        this.abortController = new AbortController()
        fetch('/convicts/search?q=' + encodeURIComponent(this.query), { signal: this.abortController.signal })
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
        this.tableTarget.style.display = 'none';
        this.resultsTarget.innerHTML = data
    }
}