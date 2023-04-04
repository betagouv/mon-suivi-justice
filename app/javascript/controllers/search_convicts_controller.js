import Rails from "@rails/ujs";
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "results", "form" ]

  search() {
    Rails.fire(this.formTarget, 'submit')
  }

  handleResults(e) {
    console.log(e)
    const [data, status, xhr] = e.detail
    this.resultsTarget.innerHTML = xhr.response
  }
}