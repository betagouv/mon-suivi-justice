import Rails from '@rails/ujs';

let placeSelect = document.getElementById('appointment-form-place-select');
let loadSlotsLink = document.getElementById('load-slots-link');
let loadSlotsButton = document.getElementById('load-slots-button');

placeSelect.addEventListener('change', (e) => {
  Rails.ajax({
    type: 'GET',
    url: '/select_slot?place_id=' + placeSelect.value
  });
});

function allowSubmitOnSlotSelection () {
  let slotsFields = document.getElementsByName('appointment[slot_id]');

  if (slotsFields.length) {
    let submitButton = document.getElementById('submit-new-appointment');

    slotsFields.forEach(field => field.addEventListener('change', () => {
      submitButton.disabled = false;
    }));
  } else {
    setTimeout(allowSubmitOnSlotSelection, 200);
  }
}

allowSubmitOnSlotSelection();
