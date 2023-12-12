import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    console.log(this.element)
    flatpickr(this.element, { mode: 'multiple', minDate: 'today'})
  }
}