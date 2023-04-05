import Rails from "@rails/ujs";
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // static targets = [ "results", "form" ]

  connect() {
    console.log("Connecté au controlleur")
  }

  selectCity(event) {
    console.log(event.params)
  }
}