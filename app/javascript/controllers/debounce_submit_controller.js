// app/javascript/controllers/search_controller.js

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  submit() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 300);
  }
}