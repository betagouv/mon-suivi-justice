import { ApplicationController, useDebounce } from 'stimulus-use'

export default class extends ApplicationController {
    static values = { allConvicts: String, myConvicts: String };
    static targets = ["results", "query", "table", "mineButton"];
    static debounces = ['search'];

    connect() {
        useDebounce(this, { wait: 500 });
        const url = new URL(window.location.href);
        const queryParams = new URLSearchParams(url.search);
        this.onlyMine = queryParams.get('only_mine') === 'true';
        this.mineButtonTarget.textContent = this.onlyMine ? this.allConvictsValue : this.myConvictsValue;
    }

    get query() {
        return this.queryTarget.value;
    }

    toggleMine(event) {
        if (this.hasMineButtonTarget) {
            event.preventDefault();
            this.onlyMine = !this.onlyMine;
            this.mineButtonTarget.textContent = this.onlyMine ? this.allConvictsValue : this.myConvictsValue;
            this.search();
        }
    }

    search() {
        if (this.query.length === 0) {
            this.reset();
            return;
        }

        if (this.query == this.previousQuery) {
            if (!this.hasMineButtonTarget) return;
        }

        this.previousQuery = this.query;

        const digitRegex = /\d/g;
        const digitCount = (this.query.match(digitRegex) || []).length;
        const nonDigitRegex = /(?!\+)\D/;
        const containsNonDigit = nonDigitRegex.test(this.query);

        if (digitCount < 4 && !containsNonDigit) {
            return;
        }

        let searchUrl = `/convicts/search?q=${encodeURIComponent(this.query)}&only_mine=${this.onlyMine}`;

        this.abortPreviousFetchRequest();

        this.abortController = new AbortController()
        fetch(searchUrl, { signal: this.abortController.signal })
            .then(response => response.text())
            .then(html => {
                this.handleResults(html);
            })
            .catch((e) => { 
                console.log(e);
            })
    }
    
    reset() {
        this.resultsTarget.innerHTML = "";
        this.queryTarget.value = "";
        this.previousQuery = null;

        if (this.hasTableTarget) {
            let redirectionUrl = this.onlyMine ? "/convicts?only_mine=true" : "/convicts?only_mine=false";
            window.location.href = redirectionUrl;
        }
    }

    abortPreviousFetchRequest() {
        if (this.abortController) {
            this.abortController.abort();
        }
    }

    handleResults(data) {
        if (this.hasTableTarget) {
            this.tableTarget.style.display = 'none';
        }

        this.resultsTarget.innerHTML = data;
    }
}