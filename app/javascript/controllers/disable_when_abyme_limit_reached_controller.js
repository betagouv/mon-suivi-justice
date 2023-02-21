import { Controller } from "@hotwired/stimulus"

// Toggle the add extra_field button depending on the limit
// this will become useless when https://github.com/eki-177/abyme/issues is done
export default class extends Controller {
  static targets = [ "addButton" ]

  connect() {
    const abymeContainer = document.getElementById("abyme--extra_fields");
    this.limitReachedbound = this.limitReached.bind(this)
    this.limitNotReachedbound = this.limitNotReached.bind(this)
    abymeContainer.addEventListener("abyme:limit-reached", this.limitReachedbound);
    abymeContainer.addEventListener("abyme:within-limit", this.limitNotReachedbound);

  }
  
  disconnect() {
    abymeContainer.removeEventListener("abyme:limit-reached", this.limitReachedbound);
    abymeContainer.removeEventListener("abyme:within-limit", this.limitNotReachedbound);
  }

  limitReached() {
    if(this.addButtonTarget.disabled) {
      return;
    }
    this.addButtonTarget.disabled = true;
  }

  limitNotReached() {
    if(!this.addButtonTarget.disabled) {
      return;
    }
    this.addButtonTarget.disabled = false;
  }
}