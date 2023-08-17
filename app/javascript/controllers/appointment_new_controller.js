import { Controller } from "@hotwired/stimulus"
import { getFieldsBelow, sendRequest } from './form_utilities'

// Handle display of the different fields
// in the create appointment form
export default class extends Controller {
  static targets = [ "selectAppointmentTypeInput", "convictSelectInput", "submitButtonContainer", "container", "selectPlaceInput", "selectAgendaInput", "submitButtonWithoutModal", "newAppointmentForm", "container" ]

  connect() {
    console.log("appointment new controller connected");
  }
  
  changeAptType() {
    const aptTypeValue = this.selectAppointmentTypeInputTarget.value;
    const convictId = this.getConvictId();
    this.resetFieldsBelow('appointmentType');
    if (this.submitButtonContainerTarget) {
      this.submitButtonContainerTarget.style.display = 'none';
    }
    sendRequest(`/load_prosecutor?apt_type_id=${aptTypeValue}`);
    sendRequest(`/load_places?apt_type_id=${aptTypeValue}&convict_id=${convictId}`);
  }

  changePlace() {
    const aptTypeId = this.selectAppointmentTypeInputTarget.value;
    const placeId = this.selectPlaceInputTarget.value;
    this.resetFieldsBelow('place');
    if (this.submitButtonContainerTarget) {
      this.submitButtonContainerTarget.style.display = 'none';
    }
    sendRequest(`/load_agendas?place_id=${placeId}&apt_type_id=${aptTypeId}`);
  }

  changeAgenda() {
    const placeId = this.selectPlaceInputTarget.value;
    const agendaId = this.selectAgendaInputTarget.value;
    const aptTypeId = this.selectAppointmentTypeInputTarget.value;
    this.resetFieldsBelow('agenda');
    sendRequest(`/load_time_options?place_id=${placeId}&agenda_id=${agendaId}&apt_type_id=${aptTypeId}`);
  }

  selectSlot() {
    if (this.submitButtonContainerTarget) {
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
}

// verifier le bon fonctionnement de la selection d'agenda en creant un second agenda a bordeaux avec des slots