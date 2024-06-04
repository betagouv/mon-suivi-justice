import Rails from '@rails/ujs';
import MicroModal from 'micromodal';

function displayAppointmentTypeSelect() {
  document.getElementById('appointment-form-title').innerHTML = `Nouvelle convocation pour ${e.params.data.text}`
  const aptTypeSelect = document.getElementById('appointment-type-container')
  aptTypeSelect.style.display = 'block';
}

const onChangeAppointmentTypeHandler = (e) => {
  const aptTypeSelect = document.getElementById('appointment_appointment_type_id');
  const convictId = getConvictId();
  console.log("id du convict", convictId);
  resetFieldsBelow('appointmentType');
  const submitButtonContainer = document.getElementById('submit-button-container');
  submitButtonContainer.style.display = 'none';
  loadTemplate.prosecutor(aptTypeSelect.value);
  loadTemplate.places(aptTypeSelect.value, convictId);
};

const STRUCTURE = {
  appointmentType: { containerId: 'appointment-type-container' },
  prosecutor: { containerId: 'prosecutor-container' },
  place: { containerId: 'places-container' },
  agenda: { containerId: 'agendas-container' },
  slot: { containerId: 'slots-container' },
  slotField: { containerId: 'slot-fields-container' },
  submit: { containerId: 'submit-button-container' }
}

const sendSms = function(with_sms) {
  var input = document.createElement("input");
  input.type = 'hidden';
  input.name = 'send_sms';
  input.value = with_sms;
  document.getElementById('submit-btn-container').prepend(input);
  document.getElementById('new_appointment').submit();
};

const getConvictId = function() {
  const convictSelect = document.getElementById('convict-name-autocomplete');

  if(convictSelect == null) {
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);

    return urlParams.get('convict_id');
  }

  return convictSelect.value
};

const resetFieldsBelow = function(identifier) {
  const current_index = Object.keys(STRUCTURE).indexOf(identifier)
  let fields_below = []

  Object.keys(STRUCTURE).forEach((key) => {
    if(Object.keys(STRUCTURE).indexOf(key) > current_index) {
      fields_below.push(key);
    }
  });

  fields_below.forEach((id) => {
    const container = document.getElementById(STRUCTURE[id].containerId);
    if(container) { container.innerHTML = '';}
  });
};

document.addEventListener('turbo:load',function() {
  const aptTypeSelect = document.getElementById('appointment_appointment_type_id');
  if (aptTypeSelect == null) { return; }
  // setupForm.appointmentType();
});

const loadTemplate = {
  sendRequest(url, onSuccess) {
    Rails.ajax({
      type: 'GET',
      url,
      success: onSuccess
    });
  },

  places(appointment_type_id, convictId) {
    const targetUrl = `/load_places?apt_type_id=${appointment_type_id}&convict_id=${convictId}`;
    this.sendRequest(targetUrl, setupForm.place);
  },

  prosecutor(appointment_type_id) {
    const targetUrl = `/load_prosecutor?apt_type_id=${appointment_type_id}`;
    this.sendRequest(targetUrl);
  },

  agendas(place_id, appointment_type_id) {
    const targetUrl = `/load_agendas?place_id=${place_id}&apt_type_id=${appointment_type_id}`;
    this.sendRequest(targetUrl, setupForm.agenda);
  },

  timeOptions(place_id, agenda_id, appointment_type_id, convict_id) {
    const targetUrl = `/load_time_options?place_id=${place_id}&agenda_id=${agenda_id}&apt_type_id=${appointment_type_id}`;
    this.sendRequest(targetUrl, () => this.submit(convict_id));
  },

  submit(convict_id) {
    const targetUrl = `/load_submit_button?convict_id=${convict_id}`;
    this.sendRequest(targetUrl, setupForm.submit);
  }
};

const setupForm = {
  appointmentType() {
    console.count('appointmentType');
    const aptTypeSelect = document.getElementById('appointment_appointment_type_id');

    // Add the event listener
    aptTypeSelect.addEventListener('change', onChangeAppointmentTypeHandler);
  },

  place() {
    const placeSelect = document.getElementById('appointment-form-place-select');
    const aptTypeSelect = document.getElementById('appointment_appointment_type_id');
    const places_container = document.getElementById('places-container');
    const submitButtonContainer = document.getElementById('submit-button-container');

    if (placeSelect) {
      placeSelect.addEventListener('change', (e) => {
        resetFieldsBelow('place');
        submitButtonContainer.style.display = 'none';

        loadTemplate.agendas(placeSelect.value, aptTypeSelect.value);
      });
    }
  },

  agenda() {
    const convictId = getConvictId()
    const convictSelect = document.getElementById('convict-name-autocomplete');
    const placeSelect = document.getElementById('appointment-form-place-select');
    const aptTypeSelect = document.getElementById('appointment_appointment_type_id');
    const agendaSelect = document.getElementById('appointment-form-agenda-select');

    if(agendaSelect == null) { loadTemplate.submit (convictId); return; }

    agendaSelect.addEventListener('change', (e) => {
      resetFieldsBelow('agenda');

      loadTemplate.timeOptions(placeSelect.value, agendaSelect.value, aptTypeSelect.value, convictId);
    });
  },

  submit() {
    MicroModal.init();

    const slotsFields = document.getElementsByName('appointment[slot_id]');
    const submitButtonContainer = document.getElementById('submit-button-container');
    const errorMessage = document.getElementsByClassName('new-appointment-form-no-slot');

    if(errorMessage.length == 1) { return; }
    slotsFields.forEach(field => field.addEventListener('change', () => {
      submitButtonContainer.style.display = 'flex';
    }));

    if(slotsFields.length == 0) { submitButtonContainer.style.display = 'flex'; }

    const submitBtnWithSms = document.getElementById('btn-modal-with-sms');
    const submitBtnWithoutSms = document.getElementById('btn-modal-without-sms');

    submitBtnWithSms.addEventListener('click', (e) => { sendSms('true') });
    submitBtnWithoutSms.addEventListener('click', (e) => { sendSms('false') });

    const submitBtnWithoutModal = document.getElementById('submit-without-modal');
    if(submitBtnWithoutModal == null) { return; }
    submitBtnWithoutModal.addEventListener('click', (e) => { sendSms('false') });
  }
};

// gerer les cas slot (sortie audience) et slot field (rdv de suivi) pour display le bouton submit
// gerer le reset des container en dessous en cas de changement de valeur en resettant les inputs plutot que les containers
// gerer le submit avec et sans modal, voir si c'est possible de gerer autrement l'envoi de sms que d'ajouter un input avec la valeur dans le form
// verifier le bon fonctionnement de la selection d'agenda en creant un second agenda a bordeaux avec des slots