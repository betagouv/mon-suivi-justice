import Rails from '@rails/ujs';
import MicroModal from 'micromodal';

document.addEventListener('turbolinks:load',function() {
  formElementAppointmentTypeSelect();
});

function displayPlaces (appointment_type_id, department_id = "") {
  let targetUrl = '/display_places?apt_type_id=' + appointment_type_id
  if (department_id !== "") { targetUrl += '&department_id=' + department_id }

  Rails.ajax({
    type: 'GET',
    url: targetUrl,
    success: function() { formElementPlaceSelect(); }
  });
}

function displayAgendas (place_id, appointment_type_id) {
  Rails.ajax({
    type: 'GET',
    url: '/display_agendas?place_id=' + place_id + '&apt_type_id=' + appointment_type_id,
    success: function() { formElementAgendaSelect(); }
  });
}

function displayDepartments (appointment_type_id) {
  Rails.ajax({
    type: 'GET',
    url: '/display_departments?apt_type_id=' + appointment_type_id,
    success: function() { formElementDepartmentSelect(); }
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

function formElementAppointmentTypeSelect() {
  const aptTypeSelect = document.getElementById('appointment_appointment_type_id');
  const slots_container = document.getElementById('slots-container');
  const agendas_container = document.getElementById('agendas-container');
  const departments_container = document.getElementById('departments-container');
  const slot_fields_container = document.getElementById('slot-fields-container');
  const submitButtonContainer = document.getElementById('submit-button-container');

  aptTypeSelect.addEventListener('change', (e) => {
    submitButtonContainer.style.display = 'none';
    if(agendas_container) { agendas_container.innerHTML = '';}
    if(departments_container) { departments_container.innerHTML = '';}
    if(slots_container) { slots_container.innerHTML = '';}
    if(slot_fields_container) { slot_fields_container.innerHTML = '';}

    displayPlaces(aptTypeSelect.value);
  });
}

function formElementPlaceSelect() {
  const placeSelect = document.getElementById('appointment-form-place-select');
  const aptTypeSelect = document.getElementById('appointment_appointment_type_id');
  // const departmentSelect = document.getElementById('appointment-form-place-select');

  const slots_container = document.getElementById('slots-container');
  const agendas_container = document.getElementById('agendas-container');
  const places_container = document.getElementById('places-container');

  const out_of_department_container = document.getElementById('appointment-out-of-department-container');
  const out_of_department_link = document.getElementById('appointment-out-of-department');
  const submitButtonContainer = document.getElementById('submit-button-container');

  // if(departmentSelect) { out_of_department_container.style.display = 'none'; }

  placeSelect.addEventListener('change', (e) => {
    submitButtonContainer.style.display = 'none';
    if(agendas_container) { agendas_container.innerHTML = ''; }
    if(slots_container) { slots_container.innerHTML = ''; }

    displayAgendas(placeSelect.value, aptTypeSelect.value);
  });

  out_of_department_link.addEventListener('click', (e) => {
    e.preventDefault();
    if(places_container) { places_container.innerHTML = '';}
    out_of_department_link.style.display = 'none';

    displayDepartments(aptTypeSelect.value);
  });
}

function formElementDepartmentSelect() {
  const departments_container = document.getElementById('departments-container');
  const places_container = document.getElementById('places-container');
  const agendas_container = document.getElementById('agendas-container');
  const departmentSelect = document.getElementById('appointment-form-department-select');
  const aptTypeSelect = document.getElementById('appointment_appointment_type_id');

  departments_container.after(places_container);

  departmentSelect.addEventListener('change', (e) => {
    if(agendas_container) { places_container.innerHTML = '';}
    displayPlaces(aptTypeSelect.value, departmentSelect.value);
  });
}

function formElementAgendaSelect() {
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

function submitFormNewAppointment (with_sms) {
  var input = document.createElement("input");
  input.type = 'hidden';
  input.name = 'send_sms';
  input.value = with_sms;
  document.getElementById('submit-btn-container').prepend(input);
  document.getElementById('new_appointment').submit();
}
