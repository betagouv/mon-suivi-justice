import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchForm", "searchField", "myConvictsCheckbox"]

  connect() {
    console.log("Convicts search controller connected");
  }

  triggerSearch(event) {
    clearTimeout(this.searchTimeout);
    this.searchTimeout = setTimeout(() => {
        console.log("Performing search...");
        this.performSearch();
    }, 300);
  }

  performSearch() {
    try {
      this.searchFormTarget.requestSubmit();
    } catch (error) {
      if (error.name !== 'AbortError') {
        console.error("An unexpected error occurred:", error);
      }
    }
  }
}
