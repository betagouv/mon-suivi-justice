// app/javascript/controllers/search_controller.js

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [ "input" ];
  connect() {
    console.log("plop")
    this.moveCursorToEnd();
  }
  submit() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.submit();
    }, 300);
  }

  moveCursorToEnd() {
    const inputElement = this.inputTarget;
    const length = inputElement.value.length;
    inputElement.focus();
    inputElement.setSelectionRange(length, length);
  }
}