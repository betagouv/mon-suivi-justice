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
  const structure = [
    "appointmentType",
    "prosecutor",
    "place",
    "agenda",
    "slot",
    "slotField"
  ];

  const currentIndex = structure.indexOf(identifier);
  if(currentIndex === -1) {
    return [];
  }
  return structure.slice(currentIndex + 1);
}