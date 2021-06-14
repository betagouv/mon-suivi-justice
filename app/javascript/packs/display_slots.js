let placeSelect = document.getElementById('appointment-form-place-select');
let loadSlotsLink = document.getElementById('load-slots-link');
let loadSlotsButton = document.getElementById('load-slots-button');
let submitButton = document.getElementById('submit-new-appointment');

placeSelect.addEventListener("change", (e) => {
  let url = new URL(loadSlotsLink.href);
  url.searchParams.set('place_id', placeSelect.value);
  loadSlotsLink.href = url.href;

  loadSlotsButton.disabled = false;
});

function allowSubmitOnSlotSelection () {
  let slotsFields = document.getElementsByName('appointment[slot_id]');

  if (slotsFields.length) {
    slotsFields.forEach(field => field.addEventListener('change', () => {
      submitButton.disabled = false;
    }));
  } else {
    setTimeout(allowSubmitOnSlotSelection, 200);
  }
}

allowSubmitOnSlotSelection();
