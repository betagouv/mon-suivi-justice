import { Controller } from "@hotwired/stimulus"
import { getFieldsBelow, sendRequest } from './form_utilities'

// Handle display of the different fields
// in the create appointment form
export default class extends Controller {
  static targets = [ "selectAppointmentTypeInput", "convictSelectInput", "submitButtonContainer", "container", "selectPlaceInput", "selectAgendaInput", "submitButtonWithoutModal", "newAppointmentForm", "sendSmsRBContainer", "sendSmsValue" ]
  
  changeAptType() {
    const aptTypeValue = this.selectAppointmentTypeInputTarget.value;
    const convictId = this.getConvictId();
    this.resetFieldsBelow('appointmentType');
    this.hideEndOfForm();
    sendRequest(`/load_prosecutor?apt_type_id=${aptTypeValue}`);
    sendRequest(`/load_places?apt_type_id=${aptTypeValue}&convict_id=${convictId}`);
  }

  changePlace() {
    const aptTypeId = this.selectAppointmentTypeInputTarget.value;
    const placeId = this.selectPlaceInputTarget.value;
    this.resetFieldsBelow('place');
    this.hideEndOfForm();
    sendRequest(`/load_agendas?place_id=${placeId}&apt_type_id=${aptTypeId}`);
  }

  changeAgenda() {
    const placeId = this.selectPlaceInputTarget.value;
    const agendaId = this.selectAgendaInputTarget.value;
    const aptTypeId = this.selectAppointmentTypeInputTarget.value;
    this.resetFieldsBelow('agenda');
    this.hideEndOfForm();
    sendRequest(`/load_time_options?place_id=${placeId}&agenda_id=${agendaId}&apt_type_id=${aptTypeId}`);
  }

  selectSlot() {
    if (this.hasSendSmsRBContainerTarget) {
      this.sendSmsRBContainerTarget.style.display = 'flex';
      const alreadySelectedRB = this.sendSmsValueTargets.some(rb => rb.checked);
      if (alreadySelectedRB) {
        this.selectSendSmsOption();
      }
    } else if (this.hasSubmitButtonContainerTarget) {
      this.submitButtonContainerTarget.style.display = 'flex';
    }
  }

  selectSendSmsOption() {
    if (this.hasSubmitButtonContainerTarget) {
      this.submitButtonContainerTarget.style.display = 'flex';
    }
  }

  submit() {
    this.newAppointmentFormTarget.submit();
  }

  getConvictId() {
    return this.convictSelectInputTarget.value
  }

  resetFieldsBelow(identifier) {
    getFieldsBelow(identifier).forEach(field => {
      const container = this.containerTargets.find(target => target.dataset.containerType === field);
      if (container) {
        container.innerHTML = '';
      }
    });
  }

  hideEndOfForm() {
    if (this.hasSubmitButtonContainerTarget) {
      this.submitButtonContainerTarget.style.display = 'none';
    }
    if (this.hasSendSmsRBContainerTarget) {
      this.sendSmsRBContainerTarget.style.display = 'none';
    }
  }

}
