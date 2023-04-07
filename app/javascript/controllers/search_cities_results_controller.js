import Rails from "@rails/ujs";
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["selectedCity", "organizationsInfo", "hiddenField"]

  connect() {
    console.log('city selector controller connected')
  }

  selectCity(event) {
    // Dispatch an event to the search controller to clear the search results
    this.dispatch("citySelected")

    const cityId = event.params.id;
    const cityName = event.params.name;

    this.selectedCityTarget.innerHTML = `<strong>Commune sélectionnée :</strong> ${cityName}`
    this.hiddenFieldTarget.value = cityId

    this.organizationsInfoTarget.hidden = true

    fetch(`/cities/${cityId}/services?`)
    .then(response => {
      if (!response.ok) {
        throw new Error("Network error");
      }
      return response.json();
    })
    .then(data => {
      if (data.length === 1) {
        this.organizationsInfoTarget.hidden = false;
        this.organizationsInfoTarget.getElementsByTagName('p')[0].innerHTML = `Attention Mon suivi Justice n’est déployé que pour le ${data[0].name}. Vous ne pourrez poursuivre la prise de rendez-vous que pour ce service et votre ressort`;
    } else if (data.length === 0) {
        this.organizationsInfoTarget.hidden = false;
        this.organizationsInfoTarget.getElementsByTagName('p')[0].innerHTML = 'Attention, Mon Suivi Justice n\' est déployé dans aucun ressort de cette commune. Vous ne pourrez poursuivre la prise de rendez-vous que pour votre ressort';
    } else {
        this.organizationsInfoTarget.hidden = true;
    }
    })
    .catch(error => {
      console.error("There was a problem with the fetch operation:", error);
    });

  }
}