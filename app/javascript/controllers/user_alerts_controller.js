
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["alert"];

    connect() {
        console.log("Hello, Stimulus!", this.element);
    }

  markAsRead(event) {
    const alertId = event.currentTarget.dataset.alertId;
    const alertElement = event.currentTarget.closest('[data-user-alerts-target="alert"]');
    
    fetch(`/user_alerts/${alertId}/mark_as_read`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        },
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        alertElement.remove();
      } else {
        alert("Il y a eu une erreur lors de la mise à jour de l'alerte")
      }
    });
  }
}
