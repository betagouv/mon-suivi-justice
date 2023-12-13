import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr"
import { French } from "flatpickr/dist/l10n/fr.js"

export default class extends Controller {
  connect() {
    console.log(this.element)
    flatpickr(this.element, { mode: 'multiple', minDate: 'today', locale: French, disable: [
      function(date) {
          // return true to disable
          return (date.getDay() === 0 || date.getDay() === 6);

      }
    ]})
  }
}