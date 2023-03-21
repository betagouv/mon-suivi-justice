import { Controller } from "@hotwired/stimulus"

// Handle display of the extra field related to the appointment type
// in the create appointment form
export default class extends Controller {
  static targets = [ "selectAppointmentTypeInput", "extraFieldsContainer", "extraFieldInputs" ]
  connect() {
    this.change();
  }
  
  change() {
    const selectAppointmentTypeOptions = this.selectAppointmentTypeInputTarget.options;
    const selectedAppointmentTypeIndex = selectAppointmentTypeOptions.selectedIndex;
    const selectedAppointmentType = selectAppointmentTypeOptions[selectedAppointmentTypeIndex];

    let shouldDisplayExtraFieldsContainer = false;
    this.extraFieldInputsTargets.forEach((input) => {
      // we get the appointment type related to the extra field
      const relatedAppointmentType = input.dataset.aptType.split(' ');

      // if the appointment type related to the extra field is the same as the selected appointment type
      const shouldDisplayInput = relatedAppointmentType.includes(selectedAppointmentType.value);
      input.disabled = !shouldDisplayInput;

      if(shouldDisplayInput) {
        shouldDisplayExtraFieldsContainer = true;
      }
    });
    this.extraFieldsContainerTarget.classList.toggle("d-none", !shouldDisplayExtraFieldsContainer);
  }
}