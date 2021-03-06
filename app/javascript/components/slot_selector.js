import Rails from '@rails/ujs';
import MicroModal from 'micromodal';

document.addEventListener('turbolinks:load',function() {
  const aptTypeSelect = document.getElementById('appointment_appointment_type_id');
  const slots_container = document.getElementById('slots-container');
  const agendas_container = document.getElementById('agendas-container');
  const slot_fields_container = document.getElementById('slot-fields-container');

  const submitButtonContainer = document.getElementById('submit-button-container');

  aptTypeSelect.addEventListener('change', (e) => {
    submitButtonContainer.style.display = 'none';
    if(agendas_container) { agendas_container.innerHTML = '';}
    if(slots_container) { slots_container.innerHTML = '';}
    if(slot_fields_container) { slot_fields_container.innerHTML = '';}

    displayPlaces(aptTypeSelect.value);
  });
});

function submitFormNewAppointment (with_sms) {
  var input = document.createElement("input");
  input.type = 'hidden';
  input.name = 'send_sms';
  input.value = with_sms;
  document.getElementById('submit-btn-container').prepend(input);
  document.getElementById('new_appointment').submit();
}

function displayPlaces (appointment_type_id) {
  Rails.ajax({
    type: 'GET',
    url: '/display_places?apt_type_id=' + appointment_type_id,
    success: function() { addListenerToPlaceSelect(); }
  });
}

function displayAgendas (place_id, appointment_type_id) {
  Rails.ajax({
    type: 'GET',
    url: '/display_agendas?place_id=' + place_id + '&apt_type_id=' + appointment_type_id,
    success: function() { addListenerToAgendaSelect(); }
  });
}

function displayTimeOptions (place_id, agenda_id, appointment_type_id, convict_id) {
  Rails.ajax({
    type: 'GET',
    url: '/display_time_options?place_id=' + place_id + '&agenda_id=' + agenda_id + '&apt_type_id=' + appointment_type_id,
    success: function() { displaySubmitButton (convict_id); }
  });
}

function displaySubmitButton (convict_id) {
  Rails.ajax({
    type: 'GET',
    url: '/display_submit_button?convict_id=' + convict_id,
    success: function() { allowSubmit(); }
  });
}

function addListenerToPlaceSelect() {
  const placeSelect = document.getElementById('appointment-form-place-select');
  const aptTypeSelect = document.getElementById('appointment_appointment_type_id');

  const slots_container = document.getElementById('slots-container');
  const agendas_container = document.getElementById('agendas-container');
  const submitButtonContainer = document.getElementById('submit-button-container');

  placeSelect.addEventListener('change', (e) => {
    submitButtonContainer.style.display = 'none';
    if(agendas_container) { agendas_container.innerHTML = '';}
    if(slots_container) { slots_container.innerHTML = '';}

    displayAgendas(placeSelect.value, aptTypeSelect.value);
  });
}

function addListenerToAgendaSelect() {
  const convictId = getConvictId()
  const convictSelect = document.getElementById('convict-name-autocomplete');
  const placeSelect = document.getElementById('appointment-form-place-select');
  const aptTypeSelect = document.getElementById('appointment_appointment_type_id');
  const agendaSelect = document.getElementById('appointment-form-agenda-select');
  const submitButtonContainer = document.getElementById('submit-button-container');

  if(agendaSelect == null) { displaySubmitButton (convictId); return; }

  const slots_container = document.getElementById('slots-container');

  agendaSelect.addEventListener('change', (e) => {
    submitButtonContainer.style.display = 'none';
    if(slots_container) { slots_container.innerHTML = '';}

    displayTimeOptions(placeSelect.value, agendaSelect.value, aptTypeSelect.value, convictId);
  });
}

function getConvictId () {
  const convictSelect = document.getElementById('convict-name-autocomplete');

  if(convictSelect == null) {
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);

    return urlParams.get('convict_id');
  }

  return convictSelect.value
}

function allowSubmit () {
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

  submitBtnWithSms.addEventListener('click', (e) => { submitFormNewAppointment('true') });
  submitBtnWithoutSms.addEventListener('click', (e) => { submitFormNewAppointment('false') });

  const submitBtnWithoutModal = document.getElementById('submit-without-modal');
  if(submitBtnWithoutModal == null) { return; }
  submitBtnWithoutModal.addEventListener('click', (e) => { submitFormNewAppointment('false') });
}
