import { Controller } from "@hotwired/stimulus"

// Handle display of the extra field related to the appointment type
// in the create appointment form
export default class extends Controller {
  static targets = [ "selectAppointmentTypeInput", "extraFieldsContainer", "extraFieldInputs" ]

  connect() {
    this.place = null;
    this.change();
  }

  changePlace(event) {
    var selectedValue = event.target.value;
    this.place = selectedValue;
    this.change();
  }
  
  change() {
    const selectAppointmentTypeOptions = this.selectAppointmentTypeInputTarget.options;
    const selectedAppointmentTypeIndex = selectAppointmentTypeOptions.selectedIndex;
    const selectedAppointmentType = selectAppointmentTypeOptions[selectedAppointmentTypeIndex];

    this.extraFieldInputsTargets.forEach((input) => {
      input.parentNode.style.display = "none";
      input.disabled = true;
      input.hidden = true;

      // we get the appointment type and organization related to the extra field
      const relatedAppointmentType = input.dataset.aptType.split(' ');
      const relatedPlaces = input.dataset.organizationPlaces.split(' ');

      /* 
      * if the appointment type related to the extra field is the same as the selected appointment type
      * and if the organization related to the extra field is the same as the selected organization
      * (we get this information from the selected place)
      * then we display the extra field
      */
      const shouldDisplayInput = relatedAppointmentType.includes(selectedAppointmentType.value) && relatedPlaces.includes(this.place);

      if (shouldDisplayInput) {
        console.log("on affiche l'input")
        input.parentNode.style.display = "block";
        input.disabled = false;
        input.hidden = false;
      }
    });
  }
}