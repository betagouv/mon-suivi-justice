import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchForm"]

  connect() {
    console.log("Convicts search controller connected");
  }

  triggerSearch() {
    clearTimeout(this.searchTimeout);
    this.searchTimeout = setTimeout(() => {
      this.searchFormTarget.requestSubmit();
    }, 300);
  }
}
