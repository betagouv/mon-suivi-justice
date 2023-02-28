import Rails from '@rails/ujs';
import MicroModal from 'micromodal';

document.addEventListener('turbolinks:load',function() {
  setupForm.appointmentType();
});

const loadTemplate = new function () {
    
  this.cities = function (convict_id) {
    console.log('convict id from cities', convict_id)
    Rails.ajax({
      type: 'GET',
      url: '/load_cities?convict_id=' + convict_id,
      success: function () { setupForm.cities(); }
    });
  };

  this.places = function(appointment_type_id, department_id = "") {
    let targetUrl = '/load_places?apt_type_id=' + appointment_type_id
    if (department_id !== "") { targetUrl += '&department_id=' + department_id }

    Rails.ajax({
      type: 'GET',
      url: targetUrl,
      success: function() { setupForm.place(); }
    });
  };

  this.prosecutor = function(appointment_type_id) {
    Rails.ajax({
      type: 'GET',
      url: '/load_prosecutor?apt_type_id=' + appointment_type_id
    });
  };

  this.departments = function(appointment_type_id) {
    Rails.ajax({
      type: 'GET',
      url: '/load_departments?apt_type_id=' + appointment_type_id,
      success: function() { setupForm.department(); }
    });
  };

  // TODO : Loader ici les communes de la PPSMJ choisies ?

  this.load_cities = function(convict_id) {
    Rails.ajax({
      type: 'GET',
      url: '/load_cities?apt_type_id=' + convict_id,
      success: function() { setupForm.cities(); }
    });
  };

  this.agendas = function(place_id, appointment_type_id) {
    Rails.ajax({
      type: 'GET',
      url: '/load_agendas?place_id=' + place_id + '&apt_type_id=' + appointment_type_id,
      success: function() { setupForm.agenda(); }
    });
  };

  this.timeOptions = function(place_id, agenda_id, appointment_type_id, convict_id) {
    Rails.ajax({
      type: 'GET',
      url: '/load_time_options?place_id=' + place_id + '&agenda_id=' + agenda_id + '&apt_type_id=' + appointment_type_id,
      success: function() { loadTemplate.submit(convict_id); }
    });
  };

  this.submit = function(convict_id) {
    Rails.ajax({
      type: 'GET',
      url: '/load_submit_button?convict_id=' + convict_id,
      success: function() { setupForm.submit(); }
    });
  };
}

const setupForm = new function() {
  const STRUCTURE = {
    appointmentType: { containerId: 'appointment-type-container' },
    prosecutor: { containerId: 'prosecutor-container' },
    department: { containerId: 'departments-container' },
    place: { containerId: 'places-container' },
    agenda: { containerId: 'agendas-container' },
    slot: { containerId: 'slots-container' },
    slotField: { containerId: 'slot-fields-container' },
    submit: { containerId: 'submit-button-container' }
  }

  this.appointmentType = function() {
    const aptTypeSelect = document.getElementById('appointment_appointment_type_id');
    const submitButtonContainer = document.getElementById('submit-button-container');

    aptTypeSelect.addEventListener('change', (e) => {
      resetFieldsBelow('appointmentType');
      submitButtonContainer.style.display = 'none';

      loadTemplate.prosecutor(aptTypeSelect.value);
      loadTemplate.places(aptTypeSelect.value);
    });
  };

  this.place = function() {
    const placeSelect = document.getElementById('appointment-form-place-select');
    const aptTypeSelect = document.getElementById('appointment_appointment_type_id');
    const departmentSelect = document.getElementById('appointment-form-department-select');
    const places_container = document.getElementById('places-container');
    const out_of_department_link = document.getElementById('appointment-out-of-department');
    const submitButtonContainer = document.getElementById('submit-button-container');

    if(departmentSelect && out_of_department_link) { out_of_department_link.style.display = 'none'; }

    placeSelect.addEventListener('change', (e) => {
      resetFieldsBelow('place');
      submitButtonContainer.style.display = 'none';

      loadTemplate.agendas(placeSelect.value, aptTypeSelect.value);
    });

    if(out_of_department_link) {
      out_of_department_link.addEventListener('click', (e) => {
        e.preventDefault();
        resetFieldsBelow('department');
        if(places_container) { places_container.innerHTML = '';}
        out_of_department_link.style.display = 'none';

        const convictId = getConvictId()

        loadTemplate.cities(convictId);
      });
    }
  };

  this.department = function() {
    const departments_container = document.getElementById('departments-container');
    const places_container = document.getElementById('places-container');
    const departmentSelect = document.getElementById('appointment-form-department-select');
    const aptTypeSelect = document.getElementById('appointment_appointment_type_id');

    departments_container.after(places_container);

    departmentSelect.addEventListener('change', (e) => {
      resetFieldsBelow('department');
      loadTemplate.places(aptTypeSelect.value, departmentSelect.value);
    });
  };

  this.cities = function () {
    const citiesSelect = document.getElementById('convict_city_id');
    const submitButtonContainer = document.getElementById('submit-button-container');

    citiesSelect.addEventListener('change', (e) => {
      resetFieldsBelow('cities');
      submitButtonContainer.style.display = 'none';

      // loadTemplate.prosecutor(citiesSelect.value);
      // loadTemplate.places(citiesSelect.value);
    });

  }

  this.agenda = function() {
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
  };

  this.submit = function() {
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
  };

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
};
