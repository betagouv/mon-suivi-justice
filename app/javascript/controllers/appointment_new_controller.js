import { Controller } from "@hotwired/stimulus"
import Rails from '@rails/ujs';
import { getFieldsBelow, sendRequest } from './form_utilities'

// Handle display of the different fields
// in the create appointment form
export default class extends Controller {
  static targets = [ "selectAppointmentTypeInput", "convictSelectInput", "submitButtonContainer", "container", "selectPlaceInput" ]

  connect() {
    console.log("appointment new controller connected");
  }
  
  changeAptType() {
    const aptTypeValue = this.selectAppointmentTypeInputTarget.value;
    const convictId = this.getConvictId();
    // this.resetFieldsBelow('appointmentType');
    if (this.submitButtonContainer) {
      this.submitButtonContainer.style.display = 'none';
    }
    sendRequest(`/load_prosecutor?apt_type_id=${aptTypeValue}`);
    sendRequest(`/load_places?apt_type_id=${aptTypeValue}&convict_id=${convictId}`);
  }

  changePlace() {
    const aptTypeId = this.selectAppointmentTypeInputTarget.value;
    const placeId = this.selectPlaceInputTarget.value;
    if (this.submitButtonContainer) {
      this.submitButtonContainer.style.display = 'none';
    }
    sendRequest(`/load_agendas?place_id=${placeId}&apt_type_id=${aptTypeId}`);
  }

  getConvictId() {
    return this.convictSelectInputTarget.value
  }

  resetFieldsBelow(identifier) {
    getFieldsBelow(identifier).forEach(field => {
      const container = this.containerTargets.find(target => target.dataset.containerType === field);
      console.log(container)
      if (container) {
        container.innerHTML = '';
      }
    });
  }
}