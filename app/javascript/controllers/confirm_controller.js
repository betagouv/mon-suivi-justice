import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    message: String
  }

  connect() {
    console.log("confirm is connected")
  }

  confirm(event) {
    if (!window.confirm(this.messageValue)) {
      event.preventDefault();
    }
  }
}