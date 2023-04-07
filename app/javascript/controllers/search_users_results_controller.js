import Rails from "@rails/ujs";
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["selectedUser", "organizationsInfo", "hiddenField"]

  connect() {
    console.log('user selector controller connected')
  }

  selectUser(event) {
    // Dispatch an event to the search controller to clear the search results
    this.dispatch("userSelected")

    const userId = event.params.id;
    const userName = event.params.name;

    this.selectedUserTarget.innerHTML = `<strong>Agent sélectionné(e) :</strong> ${userName}`
    this.hiddenFieldTarget.value = userId

  }
}