import Rails from "@rails/ujs";
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["selectedCity", "organizationsInfo", "hiddenField"]

  static values = {
    irCities: String,
    actionName: String
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
      this.organizationsInfoTarget.className = "fr-alert fr-alert--info fr-alert--sm fr-mb-3w"
      const convictCurrentOrganizations = `les services actuels du probationnaire: ${this.irCitiesValue}.`

      if (data.length > 0) {        
        const servicesList = data.map((orga) => orga.name).join(', ')
        this.organizationsInfoTarget.hidden = false;
        this.organizationsInfoTarget.getElementsByTagName('p')[0].innerHTML = `Mon suivi Justice est déployé dans les services suivants pour cette commune: <strong>${servicesList}.</strong> <br />`;
      } else {
          this.organizationsInfoTarget.hidden = false;
          this.organizationsInfoTarget.getElementsByTagName('p')[0].innerHTML = `Mon Suivi Justice n\' est déployé dans aucun service de cette commune. <br />
          Vous pourrez poursuivre la convocation uniquement dans ${this.actionNameValue == "new" ? 'votre ressort' : convictCurrentOrganizations }`
      } 
    })
    .catch(error => {
      alert("Il y a eu un problème lors de la récupération des services. Contactez support@mon-suivi-justice.beta.gouv.fr:", error);
    });

  }
}