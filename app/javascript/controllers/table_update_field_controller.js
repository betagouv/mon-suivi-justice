import { ApplicationController, useDebounce } from 'stimulus-use'
import Rails from '@rails/ujs';

export default class extends ApplicationController {
  static targets = [ "inputField" ]
  static debounces = ['update']

  connect() {
    useDebounce(this, { wait: 500 })
  }

  update() {
    const inputFieldValue = this.inputFieldTarget.value;
    console.log(this.inputFieldTarget.dataset.appointment)
    console.log(this.inputFieldTarget.dataset.extraField)
    const { appointment, extraField } = this.inputFieldTarget.dataset;
    if (inputFieldValue && appointment && extraField) {
      Rails.ajax({
        type: 'PUT',
        url: '/appointment_extra_field?appointment_id=' + appointment + '&extra_field_id=' + extraField + '&value=' + inputFieldValue
      })
    }
  }
}