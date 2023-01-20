import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "selectInputs", "valueInput" ]

  connect() {
    const abymeContainer = document.getElementById("abyme--appointment_extra_fields");
    this.boundChange = this.change.bind(this)
    abymeContainer.addEventListener("abyme:after-add", this.boundChange)
    abymeContainer.addEventListener("abyme:after-remove", this.boundChange)

  }
  
  disconnect() {
    abymeContainer.removeEventListener("abyme:after-add", this.boundChange)
    abymeContainer.removeEventListener("abyme:after-remove", this.boundChange)
  }

  change() {
    // get the selected indexes for each select input
    const selectedIndexes = this.selectInputsTargets.map((selectInput) => { return selectInput.options.selectedIndex });

    // disable options that are already selected
    this.selectInputsTargets.forEach((selectInput, index) => {
      Array.from(selectInput.options).forEach((option, optionIndex) => {
        const selectedIndexForCurrentSelect = selectedIndexes[index];
        const isDisplayable = optionIndex === selectedIndexForCurrentSelect || !selectedIndexes.includes(optionIndex);
        option.disabled = !isDisplayable;
      });
    });
  }
}