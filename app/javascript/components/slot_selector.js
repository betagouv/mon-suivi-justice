import Rails from '@rails/ujs';

document.addEventListener('turbolinks:load',function() {
  let aptTypeSelect = document.getElementById('appointment_appointment_type_id');

  let slots_container = document.getElementById('slots-container');
  let agendas_container = document.getElementById('agendas-container');

  aptTypeSelect.addEventListener('change', (e) => {
    if(agendas_container) { agendas_container.innerHTML = '';}
    if(slots_container) { slots_container.innerHTML = '';}

    displayPlaces(aptTypeSelect.value);
  });
});

function displayPlaces (appointment_type_id) {
  Rails.ajax({
    type: 'GET',
    url: '/display_places?apt_type_id=' + appointment_type_id,
    success: function() { addListenerToPlaceSelect(); }
  });
}

function displayAgendas(place_id, appointment_type_id) {
  Rails.ajax({
    type: 'GET',
    url: '/display_agendas?place_id=' + place_id + '&apt_type_id=' + appointment_type_id,
    success: function() { addListenerToAgendaSelect(); }
  });
}

function displaySlots (agenda_id, appointment_type_id) {
  Rails.ajax({
    type: 'GET',
    url: '/display_slots?agenda_id=' + agenda_id + '&apt_type_id=' + appointment_type_id,
    success: function() { allowSubmitOnSlotSelection(); }
  });
}

function addListenerToPlaceSelect() {
  let placeSelect = document.getElementById('appointment-form-place-select');
  let aptTypeSelect = document.getElementById('appointment_appointment_type_id');

  let slots_container = document.getElementById('slots-container');
  let agendas_container = document.getElementById('agendas-container');

  placeSelect.addEventListener('change', (e) => {
    if(agendas_container) { agendas_container.innerHTML = '';}
    if(slots_container) { slots_container.innerHTML = '';}

    displayAgendas(placeSelect.value, aptTypeSelect.value);
  });
}

function addListenerToAgendaSelect() {
  let aptTypeSelect = document.getElementById('appointment_appointment_type_id');
  let agendaSelect = document.getElementById('appointment-form-agenda-select');
  if(agendaSelect == null) {return;}

  let slots_container = document.getElementById('slots-container');

  agendaSelect.addEventListener('change', (e) => {
    if(slots_container) { slots_container.innerHTML = '';}

    displaySlots(agendaSelect.value, aptTypeSelect.value);
  });
}

function allowSubmitOnSlotSelection () {
  let slotsFields = document.getElementsByName('appointment[slot_id]');
  let submitButton = document.getElementById('submit-new-appointment');

  slotsFields.forEach(field => field.addEventListener('change', () => {
    submitButton.disabled = false;
  }));
}
