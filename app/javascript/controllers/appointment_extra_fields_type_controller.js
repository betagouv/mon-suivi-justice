import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "selectInput", "valueInput" ]

  change() {
    const selectedIndex = this.selectInputTarget.options.selectedIndex;
    const selected = this.selectInputTarget.options[selectedIndex];
    const dataType = selected.dataset.type;
    
    this.valueInputTarget.value = "";
    this.valueInputTarget.type = dataType;
  }
}