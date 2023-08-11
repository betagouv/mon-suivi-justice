import { Controller } from "@hotwired/stimulus"
import { getFieldsBelow, sendRequest } from './form_utilities'

// Handle display of the different fields
// in the create appointment form
export default class extends Controller {
  static targets = [ "selectAppointmentTypeInput", "convictSelectInput", "submitButtonContainer", "container", "selectPlaceInput", "selectAgendaInput", "submitButtonWithoutModal", "newAppointmentForm" ]

  connect() {
    console.log("appointment new controller connected");
    console.log(this.newAppointmentFormTarget)
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

  changeAgenda() {
    const placeId = this.selectPlaceInputTarget.value;
    const agendaId = this.selectAgendaInputTarget.value;
    const aptTypeId = this.selectAppointmentTypeInputTarget.value;

    sendRequest(`/load_time_options?place_id=${placeId}&agenda_id=${agendaId}&apt_type_id=${aptTypeId}`);
  }

  selectSlot() {
    sendRequest(`/load_submit_button?convict_id=${this.getConvictId()}`);
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
      console.log(container)
      if (container) {
        container.innerHTML = '';
      }
    });
  }
}

// gerer les cas slot (sortie audience) et slot field (rdv de suivi) pour display le bouton submit
// gerer le reset des container en dessous en cas de changement de valeur en resettant les inputs plutot que les containers
// gerer le submit avec et sans modal, voir si c'est possible de gerer autrement l'envoi de sms que d'ajouter un input avec la valeur dans le form
// verifier le bon fonctionnement de la selection d'agenda en creant un second agenda a bordeaux avec des slots
// remettre le titre (nouveau rdv pour nom du detenu) dans le formulaire