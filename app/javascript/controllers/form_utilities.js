// formUtilities.js
import Rails from '@rails/ujs';

export function sendRequest(url, onSuccess = null) {
  Rails.ajax({
    type: 'GET',
    url,
    success: onSuccess
  });
}

export function getFieldsBelow(identifier) {
  const structure = {
    appointmentType: { containerId: 'appointment-type-container' },
    prosecutor: { containerId: 'prosecutor-container' },
    department: { containerId: 'departments-container' },
    place: { containerId: 'places-container' },
    agenda: { containerId: 'agendas-container' },
    slot: { containerId: 'slots-container' },
    slotField: { containerId: 'slot-fields-container' },
    submit: { containerId: 'submit-button-container' }
  };

  const currentIndex = Object.keys(structure).indexOf(identifier);
  return Object.keys(structure).slice(currentIndex + 1);
}