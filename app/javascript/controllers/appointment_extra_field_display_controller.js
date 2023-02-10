import { Controller } from "@hotwired/stimulus"

// Handle display of the extra field related to the appointment type
// in the create appointment form
export default class extends Controller {
  static targets = [ "selectAppointmentTypeInput", "extraFieldsContainer", "extraFieldInputs" ]
  appointmentTypeRelatedToExtraFields = ["Sortie d'audience SAP"] // pas ouf d'avoir cette liste en dur
  connect() {
    this.change();
  }
  
  change() {
    const selectAppointmentTypeOptions = this.selectAppointmentTypeInputTarget.options;
    const selectedAppointmentTypeIndex = selectAppointmentTypeOptions.selectedIndex;
    const selectedAppointmentType = selectAppointmentTypeOptions[selectedAppointmentTypeIndex];
    const shouldDisplayExtraFields = this.appointmentTypeRelatedToExtraFields.includes(selectedAppointmentType.text);

    this.extraFieldsContainerTarget.classList.toggle("d-none", !shouldDisplayExtraFields);
    this.extraFieldInputsTargets.forEach((input) => {
      input.disabled = !shouldDisplayExtraFields;
    });

  }
}